import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/features/profile/image/profile_image_picker.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/auth_service.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/utils/account_validation.dart';
import 'package:travelmate/shared/utils/tag_input.dart';
import 'package:travelmate/shared/widgets/app_snackbar.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';
import 'package:travelmate/shared/widgets/editable_personal_tag_group.dart';
import 'package:travelmate/shared/widgets/profile_photo.dart';
import 'package:travelmate/shared/widgets/settings_action_button.dart';

/// Persists newly created credentials. Injectable for testing.
typedef AccountCreator =
    Future<void> Function(String username, String password);

/// Picks a profile photo and returns its stored path. Injectable for testing.
typedef ProfilePhotoPicker = Future<String?> Function();

/// Sign-up screen: profile identity (name, surname, description, tags, photo)
/// plus new login credentials.
///
/// On submit the fields are validated, the credentials are stored through the
/// encrypted SQLite account (username AES-encrypted, password PBKDF2-hashed),
/// the profile is persisted, and the app opens on the new profile. Because the
/// account/profile are single-row, this overwrites any existing account.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    super.key,
    this.createAccount,
    this.onCreated,
    this.photoPicker,
  });

  /// Stores the new credentials. Defaults to [AuthService].
  final AccountCreator? createAccount;

  /// Invoked after a successful creation. Defaults to opening the app shell.
  final ValueChanged<BuildContext>? onCreated;

  /// Picks a profile photo. Defaults to the real gallery picker.
  final ProfilePhotoPicker? photoPicker;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const String _defaultPhotoAsset = 'assets/icons/user_icon.svg';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _interestTagInputController =
      TextEditingController();
  final TextEditingController _tripTagInputController = TextEditingController();

  List<String> _interestTags = <String>[];
  List<String> _tripTags = <String>[];
  String _photoAsset = _defaultPhotoAsset;
  bool _submitting = false;

  String? _nameError;
  String? _surnameError;
  String? _descriptionError;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _descriptionController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _interestTagInputController.dispose();
    _tripTagInputController.dispose();
    super.dispose();
  }

  ProfilePhotoPicker get _photoPicker =>
      widget.photoPicker ?? const ProfileImagePicker().pickAndStore;

  void _addInterestTag() {
    final updated = TagInput.tryAdd(
      _interestTags,
      _interestTagInputController.text,
    );
    _interestTagInputController.clear();
    if (updated != null) {
      setState(() => _interestTags = updated);
    }
  }

  void _addTripTag() {
    final updated = TagInput.tryAdd(_tripTags, _tripTagInputController.text);
    _tripTagInputController.clear();
    if (updated != null) {
      setState(() => _tripTags = updated);
    }
  }

  void _removeInterestTag(String tag) {
    setState(() => _interestTags = TagInput.remove(_interestTags, tag));
  }

  void _removeTripTag(String tag) {
    setState(() => _tripTags = TagInput.remove(_tripTags, tag));
  }

  Future<void> _uploadPhoto() async {
    final messenger = ScaffoldMessenger.of(context);

    final String? path;
    try {
      path = await _photoPicker();
    } catch (_) {
      AppSnackBar.show(messenger, AppStrings.createAccountPhotoError);
      return;
    }

    if (path == null || !mounted) {
      return;
    }

    setState(() => _photoAsset = path!);
  }

  bool _validate() {
    final nameError = AccountValidation.validateRequiredName(
      _nameController.text,
      AppStrings.createAccountNameLabel,
    );
    final surnameError = AccountValidation.validateRequiredName(
      _surnameController.text,
      AppStrings.createAccountSurnameLabel,
    );
    final descriptionError = AccountValidation.validateDescription(
      _descriptionController.text,
    );
    final usernameError = AccountValidation.validateUsername(
      _usernameController.text,
    );
    final passwordError = AccountValidation.validatePassword(
      _passwordController.text,
    );

    setState(() {
      _nameError = nameError;
      _surnameError = surnameError;
      _descriptionError = descriptionError;
      _usernameError = usernameError;
      _passwordError = passwordError;
    });

    return nameError == null &&
        surnameError == null &&
        descriptionError == null &&
        usernameError == null &&
        passwordError == null;
  }

  Future<void> _handleCreate() async {
    if (_submitting || !_validate()) {
      return;
    }

    setState(() => _submitting = true);

    final createAccount =
        widget.createAccount ?? AuthService.instance.createAccount;
    await createAccount(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    PersonalProfileStore.instance.updateProfile(
      PersonalProfile(
        firstName: _nameController.text.trim(),
        lastName: _surnameController.text.trim(),
        description: _descriptionController.text.trim(),
        photoAsset: _photoAsset,
        interestTags: TagInput.clean(_interestTags),
        tripTags: TagInput.clean(_tripTags),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);
    (widget.onCreated ?? _openApp)(context);
  }

  void _openApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.createAccountTitle,
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            sizes.padL,
            sizes.padL,
            sizes.padL,
            sizes.padL * 1.4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: AppStrings.createAccountNameLabel,
                errorText: _nameError,
              ),
              SizedBox(height: sizes.padS),
              AppTextField(
                controller: _surnameController,
                label: AppStrings.createAccountSurnameLabel,
                errorText: _surnameError,
              ),
              SizedBox(height: sizes.padS),
              AppTextField(
                controller: _descriptionController,
                label: AppStrings.createAccountDescriptionLabel,
                maxLines: 4,
                minLines: 3,
                errorText: _descriptionError,
              ),
              SizedBox(height: sizes.spaceS),
              _PhotoField(photoAsset: _photoAsset, onUpload: _uploadPhoto),
              SizedBox(height: sizes.spaceS),
              EditablePersonalTagGroup(
                title: AppStrings.createAccountInterestTagsTitle,
                fieldLabel: AppStrings.createAccountInterestTagField,
                emptyText: AppStrings.createAccountInterestTagEmpty,
                inputController: _interestTagInputController,
                tags: _interestTags,
                onAddPressed: _addInterestTag,
                onRemoveTag: _removeInterestTag,
                paletteOffset: 0,
              ),
              SizedBox(height: sizes.spaceS),
              EditablePersonalTagGroup(
                title: AppStrings.createAccountTripTagsTitle,
                fieldLabel: AppStrings.createAccountTripTagField,
                emptyText: AppStrings.createAccountTripTagEmpty,
                inputController: _tripTagInputController,
                tags: _tripTags,
                onAddPressed: _addTripTag,
                onRemoveTag: _removeTripTag,
                paletteOffset: 3,
              ),
              SizedBox(height: sizes.spaceM),
              AppTextField(
                controller: _usernameController,
                label: AppStrings.createAccountUsernameLabel,
                errorText: _usernameError,
              ),
              SizedBox(height: sizes.padS),
              AppTextField(
                controller: _passwordController,
                label: AppStrings.createAccountPasswordLabel,
                obscureText: true,
                errorText: _passwordError,
              ),
              SizedBox(height: sizes.spaceM),
              CustomButton(
                text: AppStrings.createAccountSubmitLabel,
                color: AppColors.yellow,
                onPressed: _submitting ? () {} : _handleCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.photoAsset, required this.onUpload});

  final String photoAsset;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final previewSize = (sizes.sliderTileSize * 0.5)
        .clamp(72.0, 120.0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.createAccountPhotoLabel,
          style: AppTextStyles.bodyMd(
            sizes,
          ).copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: sizes.padS),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(previewSize * 0.5),
              child: Container(
                width: previewSize,
                height: previewSize,
                color: const Color(0xFFFFFCED),
                child: ProfilePhoto(source: photoAsset, size: previewSize),
              ),
            ),
            SizedBox(width: sizes.padM),
            Expanded(
              child: SettingsActionButton(
                label: AppStrings.createAccountUploadPhotoLabel,
                color: AppColors.linkBlue,
                textColor: AppColors.black,
                iconColor: AppColors.linkBlue,
                onTap: onUpload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
