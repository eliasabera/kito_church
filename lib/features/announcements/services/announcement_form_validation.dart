/// Validation limits for the create-announcement form.
class AnnouncementFormValidation {
  AnnouncementFormValidation._();

  static const titleMinLength = 3;
  static const titleMaxLength = 120;
  static const messageMinLength = 10;
  static const messageMaxLength = 5000;
  static const authorMinLength = 2;
  static const authorMaxLength = 80;
  static const categoryNameMinLength = 2;
  static const categoryNameMaxLength = 40;
}
