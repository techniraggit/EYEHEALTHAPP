class ApiProvider{

   //static const baseUrl = "http://192.168.29.221:8000";
  static const baseUrl = "https://eyehealth.backend.zuktiinnovations.com";

  static const verifyEmailOtp = "/api/verification_otp";//verify email during signup
  static const sendVerifyOtp = "/api/verification_otp";
  static const register = "/api/register";
  static const sendLoginOtp = "/api/send_login_otp";
  static const verifyLoginOtp = "/api/verify_login_otp";
  static const validateReferralCode_ = "/api/validate_referral_code";
  static const getUserProfile = "/api/profile";
  static const myReffrealcontacts ='/api/my-referrals';
  static const updateUserProfile = "/api/profile";
  static const updateProfilepic='/api/profile';
  static const get_notification='/api/user_notification';
  static const update_notification_status='/api/user_notification';
  static const getOffers_detail='/api/offers';
  static const uploadPrescription='/api/prescription';
  static const getaddress='/api/address';
  static const verifyuser= '/api/is_already_verified?username=';
  static const isActivePlan='/api/is-active-plan';
  static const isAgreement='/api/agreement';
  static const deleteUser='/api/delete-account';






}

