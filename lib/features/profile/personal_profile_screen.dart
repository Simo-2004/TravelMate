import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/profile/image/profile_image_picker.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/utils/tag_input.dart';
import 'package:travelmate/shared/widgets/app_snackbar.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/editable_personal_tag_group.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/personal_tag_group.dart';
import 'package:travelmate/shared/widgets/profile_photo.dart';
import 'package:travelmate/shared/widgets/settings_action_button.dart';
import 'package:travelmate/shared/widgets/settings_action_card.dart';

/// Picks a profile photo and returns its stored file path (or null if
/// cancelled). Injectable so tests can bypass the `image_picker` plugin.
typedef ProfilePhotoPicker = Future<String?> Function();

/// Editable personal profile page with identity, photo, and personal tags.
class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key, this.photoPicker});

  /// Defaults to the real gallery picker; overridden in tests.
  final ProfilePhotoPicker? photoPicker;

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  static const String _userIconAsset = 'assets/icons/user_icon.svg';

  static const List<String> _photoOptions = [
    _userIconAsset,
    'assets/icons/mate_avatar_1.svg',
    'assets/icons/mate_avatar_2.svg',
    'assets/icons/mate_avatar_3.svg',
  ];

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _interestTagInputController;
  late final TextEditingController _tripTagInputController;
  late String _selectedPhotoAsset;
  late List<String> _photoChoices;
  late List<String> _interestTags;
  late List<String> _tripTags;
  bool _isEditing = false;

  ProfilePhotoPicker get _photoPicker =>
      widget.photoPicker ?? const ProfileImagePicker().pickAndStore;

  /// Bundled asset options plus any uploaded file path currently selected, so
  /// a just-picked photo appears as a selectable (highlighted) choice.
  List<String> _buildPhotoChoices() {
    final selected = _selectedPhotoAsset;
    if (selected.isEmpty || _photoOptions.contains(selected)) {
      return List<String>.from(_photoOptions);
    }

    return <String>[selected, ..._photoOptions];
  }

  @override
  void initState() {
    super.initState();
    final profile = PersonalProfileStore.instance.value;

    _firstNameController = TextEditingController(text: profile.firstName)
      ..addListener(_handleFieldChanged);
    _lastNameController = TextEditingController(text: profile.lastName)
      ..addListener(_handleFieldChanged);
    _descriptionController = TextEditingController(text: profile.description)
      ..addListener(_handleFieldChanged);
    _interestTagInputController = TextEditingController();
    _tripTagInputController = TextEditingController();

    _applyProfileToDraft(profile);
  }

  @override
  void dispose() {
    _firstNameController
      ..removeListener(_handleFieldChanged)
      ..dispose();
    _lastNameController
      ..removeListener(_handleFieldChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_handleFieldChanged)
      ..dispose();
    _interestTagInputController.dispose();
    _tripTagInputController.dispose();
    super.dispose();
  }

  void _handleFieldChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  String _resolvedFirstName() {
    final value = _firstNameController.text.trim();
    return value.isEmpty
        ? PersonalProfileStore.instance.value.firstName
        : value;
  }

  String _resolvedLastName() {
    final value = _lastNameController.text.trim();
    return value.isEmpty ? PersonalProfileStore.instance.value.lastName : value;
  }

  String _resolvedDescription() {
    final value = _descriptionController.text.trim();
    return value.isEmpty
        ? PersonalProfileStore.instance.value.description
        : value;
  }

  List<String> _cleanTagList(List<String> source) => TagInput.clean(source);

  void _addTag({required bool isInterestTag}) {
    final controller = isInterestTag
        ? _interestTagInputController
        : _tripTagInputController;
    final currentTags = isInterestTag ? _interestTags : _tripTags;
    final updated = TagInput.tryAdd(currentTags, controller.text);
    controller.clear();

    if (updated == null) {
      return;
    }

    setState(() {
      if (isInterestTag) {
        _interestTags = updated;
      } else {
        _tripTags = updated;
      }
    });
  }

  void _removeTag(String tag, {required bool isInterestTag}) {
    setState(() {
      if (isInterestTag) {
        _interestTags = TagInput.remove(_interestTags, tag);
      } else {
        _tripTags = TagInput.remove(_tripTags, tag);
      }
    });
  }

  void _addInterestTag() => _addTag(isInterestTag: true);

  void _addTripTag() => _addTag(isInterestTag: false);

  void _removeInterestTag(String tag) => _removeTag(tag, isInterestTag: true);

  void _removeTripTag(String tag) => _removeTag(tag, isInterestTag: false);

  void _applyProfileToDraft(PersonalProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _descriptionController.text = profile.description;
    _selectedPhotoAsset = profile.photoAsset;
    _photoChoices = _buildPhotoChoices();
    _interestTags = List<String>.from(_cleanTagList(profile.interestTags));
    _tripTags = List<String>.from(_cleanTagList(profile.tripTags));
    _interestTagInputController.clear();
    _tripTagInputController.clear();
  }

  void _startEditing() {
    final current = PersonalProfileStore.instance.value;
    setState(() {
      _applyProfileToDraft(current);
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    final current = PersonalProfileStore.instance.value;
    setState(() {
      _applyProfileToDraft(current);
      _isEditing = false;
    });
  }

  void _selectPhoto(String asset) {
    setState(() {
      _selectedPhotoAsset = asset;
      _photoChoices = _buildPhotoChoices();
    });
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final String? path;
    try {
      path = await _photoPicker();
    } catch (_) {
      AppSnackBar.show(messenger, 'Could not load the selected photo.');
      return;
    }

    if (path == null || !mounted) {
      return;
    }

    _selectPhoto(path);
  }

  void _saveProfile(BuildContext context) {
    final updated = PersonalProfile(
      firstName: _resolvedFirstName(),
      lastName: _resolvedLastName(),
      description: _resolvedDescription(),
      photoAsset: _selectedPhotoAsset,
      interestTags: _cleanTagList(_interestTags),
      tripTags: _cleanTagList(_tripTags),
    );

    PersonalProfileStore.instance.updateProfile(updated);

    setState(() {
      _isEditing = false;
      _applyProfileToDraft(updated);
    });

    AppSnackBar.show(
      ScaffoldMessenger.of(context),
      'Personal profile updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final previewProfile = PersonalProfile(
      firstName: _resolvedFirstName(),
      lastName: _resolvedLastName(),
      description: _resolvedDescription(),
      photoAsset: _selectedPhotoAsset,
      interestTags: _cleanTagList(_interestTags),
      tripTags: _cleanTagList(_tripTags),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.padL,
              sizes.padL,
              sizes.padL,
              sizes.padL * 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sizes.padS),
                MateDetailsPanel(
                  name: previewProfile.fullName,
                  description: previewProfile.description,
                  profileImageAsset: previewProfile.photoAsset,
                ),
                PersonalTagGroup(
                  title: 'Personal interests',
                  tags: previewProfile.interestTags,
                  paletteOffset: 0,
                ),
                PersonalTagGroup(
                  title: 'Personal trip tags',
                  tags: previewProfile.tripTags,
                  paletteOffset: 3,
                ),
                SizedBox(height: sizes.spaceM),
                SettingsActionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isEditing)
                        SettingsActionButton(
                          label: 'Edit profile',
                          color: AppColors.yellow,
                          iconAsset: _userIconAsset,
                          textColor: AppColors.black,
                          iconColor: AppColors.yellow,
                          onTap: _startEditing,
                        ),
                      if (_isEditing) ...[
                        Text(
                          'Edit your profile',
                          style: AppTextStyles.titleLg(
                            sizes,
                          ).copyWith(fontSize: sizes.textMd),
                        ),
                        SizedBox(height: sizes.padS),
                        AppTextField(
                          label: 'Name',
                          controller: _firstNameController,
                        ),
                        SizedBox(height: sizes.padS),
                        AppTextField(
                          label: 'Surname',
                          controller: _lastNameController,
                        ),
                        SizedBox(height: sizes.padS),
                        AppTextField(
                          label: 'Description',
                          controller: _descriptionController,
                          maxLines: 4,
                          minLines: 3,
                        ),
                        SizedBox(height: sizes.padS),
                        Text(
                          'Photo',
                          style: AppTextStyles.bodyMd(
                            sizes,
                          ).copyWith(color: AppColors.black),
                        ),
                        SizedBox(height: sizes.padXs),
                        Wrap(
                          spacing: sizes.padS,
                          runSpacing: sizes.padS,
                          children: _photoChoices
                              .map(
                                (asset) => _PhotoOptionButton(
                                  asset: asset,
                                  selected: _selectedPhotoAsset == asset,
                                  onTap: () => _selectPhoto(asset),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        SizedBox(height: sizes.padS),
                        SettingsActionButton(
                          label: 'Upload photo',
                          color: const Color(0xFF2F80ED),
                          iconAsset: _userIconAsset,
                          textColor: AppColors.black,
                          iconColor: const Color(0xFF2F80ED),
                          onTap: () => _uploadPhoto(context),
                        ),
                        SizedBox(height: sizes.spaceM),
                        EditablePersonalTagGroup(
                          title: 'Personal interest tags',
                          fieldLabel: 'Type and add an interest tag',
                          emptyText: 'No personal interest tags yet.',
                          inputController: _interestTagInputController,
                          tags: _interestTags,
                          onAddPressed: _addInterestTag,
                          onRemoveTag: _removeInterestTag,
                          paletteOffset: 0,
                        ),
                        SizedBox(height: sizes.spaceS),
                        EditablePersonalTagGroup(
                          title: 'Personal trip tags',
                          fieldLabel: 'Type and add a trip tag',
                          emptyText: 'No personal trip tags yet.',
                          inputController: _tripTagInputController,
                          tags: _tripTags,
                          onAddPressed: _addTripTag,
                          onRemoveTag: _removeTripTag,
                          paletteOffset: 3,
                        ),
                        SizedBox(height: sizes.spaceM),
                        SettingsActionButton(
                          label: 'Save profile changes',
                          color: AppColors.yellow,
                          iconAsset: _userIconAsset,
                          textColor: AppColors.black,
                          iconColor: AppColors.yellow,
                          onTap: () => _saveProfile(context),
                        ),
                        SizedBox(height: sizes.padS),
                        SettingsActionButton(
                          label: 'Cancel',
                          color: const Color(0xFFFF5353),
                          iconAsset: 'assets/icons/exit.svg',
                          onTap: _cancelEditing,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _PhotoOptionButton({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final side = (sizes.sliderTileSize * 0.28).clamp(56.0, 84.0).toDouble();

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(sizes.radiusM),
      child: InkWell(
        borderRadius: BorderRadius.circular(sizes.radiusM),
        onTap: onTap,
        child: Container(
          width: side,
          height: side,
          padding: EdgeInsets.all(sizes.padXs * 0.9),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCED),
            borderRadius: BorderRadius.circular(sizes.radiusM),
            border: Border.all(
              color: selected ? AppColors.yellow : AppColors.blackAlpha60,
              width: selected ? sizes.padXs * 0.34 : sizes.padXs * 0.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(sizes.radiusM),
            child: ProfilePhoto(source: asset, size: side),
          ),
        ),
      ),
    );
  }
}
