import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/providers/album/current_album.provider.dart';
import 'package:immich_mobile/providers/album/shared_album.provider.dart';
import 'package:immich_mobile/providers/asset_viewer/asset_stack.provider.dart';
import 'package:immich_mobile/providers/asset_viewer/image_viewer_page_state.provider.dart';
import 'package:immich_mobile/providers/asset_viewer/show_controls.provider.dart';
import 'package:immich_mobile/services/asset_stack.service.dart';
import 'package:immich_mobile/widgets/asset_grid/asset_grid_data_structure.dart';
import 'package:immich_mobile/widgets/asset_viewer/video_controls.dart';
import 'package:immich_mobile/widgets/asset_grid/delete_dialog.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/entities/asset.entity.dart';
import 'package:immich_mobile/providers/asset.provider.dart';
import 'package:immich_mobile/providers/server_info.provider.dart';
import 'package:immich_mobile/providers/user.provider.dart';
import 'package:immich_mobile/widgets/common/immich_toast.dart';
import 'package:immich_mobile/pages/editing/edit.page.dart';

class BottomGalleryBar extends ConsumerWidget {
  final Asset asset;
  final ValueNotifier<int> assetIndex;
  final bool showStack;
  final int stackIndex;
  final ValueNotifier<int> totalAssets;
  final bool showVideoPlayerControls;
  final PageController controller;
  final RenderList renderList;

  const BottomGalleryBar({
    super.key,
    required this.showStack,
    required this.stackIndex,
    required this.asset,
    required this.assetIndex,
    required this.controller,
    required this.totalAssets,
    required this.showVideoPlayerControls,
    required this.renderList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = asset.ownerId == ref.watch(currentUserProvider)?.isarId;

    final stack = showStack && asset.stackChildrenCount > 0
        ? ref.watch(assetStackStateProvider(asset))
        : <Asset>[];
    final stackElements = showStack ? [asset, ...stack] : <Asset>[];
    bool isParent = stackIndex == -1 || stackIndex == 0;
    final navStack = AutoRouter.of(context).stackData;
    final isTrashEnabled =
        ref.watch(serverInfoProvider.select((v) => v.serverFeatures.trash));
    final isFromTrash = isTrashEnabled &&
        navStack.length > 2 &&
        navStack.elementAt(navStack.length - 2).name == TrashRoute.name;
    final isInAlbum = ref.watch(currentAlbumProvider)?.isRemote ?? false;

    void removeAssetFromStack() {
      if (stackIndex > 0 && showStack) {
        ref
            .read(assetStackStateProvider(asset).notifier)
            .removeChild(stackIndex - 1);
      }
    }

    void handleDelete() async {
      Future<bool> onDelete(bool force) async {
        final isDeleted = await ref.read(assetProvider.notifier).deleteAssets(
          {asset},
          force: force,
        );
        if (isDeleted && isParent) {
          // Workaround for asset remaining in the gallery
          renderList.deleteAsset(asset);

          // `assetIndex == totalAssets.value - 1` handle the case of removing the last asset
          // to not throw the error when the next preCache index is called
          if (totalAssets.value == 1 ||
              assetIndex.value == totalAssets.value - 1) {
            // Handle only one asset
            context.maybePop();
          }

          totalAssets.value -= 1;
        }
        return isDeleted;
      }

      // Asset is trashed
      if (isTrashEnabled && !isFromTrash) {
        final isDeleted = await onDelete(false);
        if (isDeleted) {
          // Can only trash assets stored in server. Local assets are always permanently removed for now
          if (context.mounted && asset.isRemote && isParent) {
            ImmichToast.show(
              durationInSecond: 1,
              context: context,
              msg: 'Asset trashed',
              gravity: ToastGravity.BOTTOM,
            );
          }
          removeAssetFromStack();
        }
        return;
      }

      // Asset is permanently removed
      showDialog(
        context: context,
        builder: (BuildContext _) {
          return DeleteDialog(
            onDelete: () async {
              final isDeleted = await onDelete(true);
              if (isDeleted) {
                removeAssetFromStack();
              }
            },
          );
        },
      );
    }

    void showStackActionItems() {
      showModalBottomSheet<void>(
        context: context,
        enableDrag: false,
        builder: (BuildContext ctx) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isParent)
                    ListTile(
                      leading: const Icon(
                        Icons.bookmark_border_outlined,
                        size: 24,
                      ),
                      onTap: () async {
                        await ref
                            .read(assetStackServiceProvider)
                            .updateStackParent(
                              asset,
                              stackElements.elementAt(stackIndex),
                            );
                        ctx.pop();
                        context.maybePop();
                      },
                      title: const Text(
                        "viewer_stack_use_as_main_asset",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ).tr(),
                    ),
                  ListTile(
                    leading: const Icon(
                      Icons.copy_all_outlined,
                      size: 24,
                    ),
                    onTap: () async {
                      if (isParent) {
                        await ref
                            .read(assetStackServiceProvider)
                            .updateStackParent(
                              asset,
                              stackElements
                                  .elementAt(1), // Next asset as parent
                            );
                        // Remove itself from stack
                        await ref.read(assetStackServiceProvider).updateStack(
                          stackElements.elementAt(1),
                          childrenToRemove: [asset],
                        );
                        ctx.pop();
                        context.maybePop();
                      } else {
                        await ref.read(assetStackServiceProvider).updateStack(
                          asset,
                          childrenToRemove: [
                            stackElements.elementAt(stackIndex),
                          ],
                        );
                        removeAssetFromStack();
                        ctx.pop();
                      }
                    },
                    title: const Text(
                      "viewer_remove_from_stack",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.filter_none_outlined,
                      size: 18,
                    ),
                    onTap: () async {
                      await ref.read(assetStackServiceProvider).updateStack(
                            asset,
                            childrenToRemove: stack,
                          );
                      ctx.pop();
                      context.maybePop();
                    },
                    title: const Text(
                      "viewer_unstack",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    shareAsset() {
      if (asset.isOffline) {
        ImmichToast.show(
          durationInSecond: 1,
          context: context,
          msg: 'asset_action_share_err_offline'.tr(),
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }
      ref.read(imageViewerStateProvider.notifier).shareAsset(asset, context);
    }

    void handleEdit() async {
      if (asset.isOffline) {
        ImmichToast.show(
          durationInSecond: 1,
          context: context,
          msg: 'asset_action_edit_err_offline'.tr(),
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              EditImagePage(asset: asset), // Send the Asset object
        ),
      );
    }

    handleArchive() {
      ref.read(assetProvider.notifier).toggleArchive([asset]);
      if (isParent) {
        context.maybePop();
        return;
      }
      removeAssetFromStack();
    }

    handleDownload() {
      if (asset.isLocal) {
        return;
      }
      if (asset.isOffline) {
        ImmichToast.show(
          durationInSecond: 1,
          context: context,
          msg: 'asset_action_share_err_offline'.tr(),
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      ref.read(imageViewerStateProvider.notifier).downloadAsset(
            asset,
            context,
          );
    }

    handleRemoveFromAlbum() async {
      final album = ref.read(currentAlbumProvider);
      final bool isSuccess = album != null &&
          await ref
              .read(sharedAlbumProvider.notifier)
              .removeAssetFromAlbum(album, [asset]);

      if (isSuccess) {
        // Workaround for asset remaining in the gallery
        renderList.deleteAsset(asset);

        if (totalAssets.value == 1) {
          // Handle empty viewer
          await context.maybePop();
        } else {
          // changing this also for the last asset causes the parent to rebuild with an error
          totalAssets.value -= 1;
        }
        if (assetIndex.value == totalAssets.value && assetIndex.value > 0) {
          // handle the case of removing the last asset in the list
          assetIndex.value -= 1;
        }
      } else {
        ImmichToast.show(
          context: context,
          msg: "album_viewer_appbar_share_err_remove".tr(),
          toastType: ToastType.error,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }

    final List<Map<BottomNavigationBarItem, Function(int)>> albumActions = [
      {
        BottomNavigationBarItem(
          icon: Icon(
            Platform.isAndroid ? Icons.share_rounded : Icons.ios_share_rounded,
          ),
          label: 'control_bottom_app_bar_share'.tr(),
          tooltip: 'control_bottom_app_bar_share'.tr(),
        ): (_) => shareAsset(),
      },
      if (asset.isImage)
        {
          BottomNavigationBarItem(
            icon: const Icon(Icons.tune_outlined),
            label: 'control_bottom_app_bar_edit'.tr(),
            tooltip: 'control_bottom_app_bar_edit'.tr(),
          ): (_) => handleEdit(),
        },
      if (isOwner)
        {
          asset.isArchived
              ? BottomNavigationBarItem(
                  icon: const Icon(Icons.unarchive_rounded),
                  label: 'control_bottom_app_bar_unarchive'.tr(),
                  tooltip: 'control_bottom_app_bar_unarchive'.tr(),
                )
              : BottomNavigationBarItem(
                  icon: const Icon(Icons.archive_outlined),
                  label: 'control_bottom_app_bar_archive'.tr(),
                  tooltip: 'control_bottom_app_bar_archive'.tr(),
                ): (_) => handleArchive(),
        },
      if (isOwner && stack.isNotEmpty)
        {
          BottomNavigationBarItem(
            icon: const Icon(Icons.burst_mode_outlined),
            label: 'control_bottom_app_bar_stack'.tr(),
            tooltip: 'control_bottom_app_bar_stack'.tr(),
          ): (_) => showStackActionItems(),
        },
      if (isOwner && !isInAlbum)
        {
          BottomNavigationBarItem(
            icon: const Icon(Icons.delete_outline),
            label: 'control_bottom_app_bar_delete'.tr(),
            tooltip: 'control_bottom_app_bar_delete'.tr(),
          ): (_) => handleDelete(),
        },
      if (!isOwner)
        {
          BottomNavigationBarItem(
            icon: const Icon(Icons.download_outlined),
            label: 'download'.tr(),
            tooltip: 'download'.tr(),
          ): (_) => handleDownload(),
        },
      if (isInAlbum)
        {
          BottomNavigationBarItem(
            icon: const Icon(Icons.remove_circle_outline),
            label: 'album_viewer_appbar_share_remove'.tr(),
            tooltip: 'album_viewer_appbar_share_remove'.tr(),
          ): (_) => handleRemoveFromAlbum(),
        },
    ];
    return IgnorePointer(
      ignoring: !ref.watch(showControlsProvider),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: ref.watch(showControlsProvider) ? 1.0 : 0.0,
        child: Column(
          children: [
            Visibility(
              visible: showVideoPlayerControls,
              child: const VideoControls(),
            ),
            BottomNavigationBar(
              backgroundColor: Colors.black.withOpacity(0.4),
              unselectedIconTheme: const IconThemeData(color: Colors.white),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedLabelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 2.3,
              ),
              selectedLabelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 2.3,
              ),
              unselectedFontSize: 14,
              selectedFontSize: 14,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items:
                  albumActions.map((e) => e.keys.first).toList(growable: false),
              onTap: (index) {
                albumActions[index].values.first.call(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
