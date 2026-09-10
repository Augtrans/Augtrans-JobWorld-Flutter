class Constants {

  // Base URL
  //static const String BASE_URL = 'http://192.168.130.115:8000';
  //static const String BASE_URL = 'http://192.168.130.56:8000';
  static const String BASE_URL = 'http://172.16.16.206:8000';
  static const bool IS_RAZORPAY_LIVE = false;
  static const bool IS_LOG = true;

  // For converting date
  static const String inputFormatPattern1 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const String inputFormatPattern2 = "yyyy-MM-dd";
  static const String inputFormatPattern3 = "yyyy-mm-dd HH:mm:ss.SSS";

  //To yyyy-mm-dd
  static const String format3 = "EEE MMM dd HH:mm:ss z yyyy";
  static const String format4 = "MMMM yyyy";
  static const String format5 = "dd-MM-yyyy, HH:mm a";

  static const String outputFormatPattern1 = "MMMM dd, yyyy";
  static const String outputFormatPattern2 = "dd-MM-yyyy";
  static const String outputFormatPattern3 = "EEEE, MMMM dd, yyyy"; // Output as "Friday, July 23, 2021"
  static const String outputFormatPattern4 = "yyyy-MM-dd";

  static const String LOGIN_TOKEN = "login_token";
  static const String CONTACT_NO = "contact_no";
  static const String EMAIL_ID = "email_id";
  static const String USER_ID = "user_id";
  static const String IS_USER_DETAILS = "is_user_details";
  static const String IS_TEMP_USER = "is_temp_user";
  static const String DELIVERY_ADDRESS = "delivery_address";
  static const String FULL_NAME = "full_name";
  static const String LAT = "lat";
  static const String LNG = "lng";
  static const String LAST_SPLASH_API_CALL = "LastSplashApiCall";
  static const String SHOULD_ASK_USER_LOCATION = "should_ask_user_location";
  static const String FCM_TOKEN = "fcm_token";
  static const String PERMISSION_DIALOG_COUNT = "permission_dialog_count";
  static const String HUB_NAME = "hub_name";
  static const String HUB_ID = "hub_id";
  static const String LOCATION_NAME = "location_name";
  static const String COMPANY_ID = "companyID";
  static const String AUTHORIZATION = "Authorization";
  static const String OVINO = "OVINO";
  static const String SOMETHING_WENT_WRONG = "Something Went Wrong. Please try again later...";
  static const String SHOULD_SHOW_INTRO = "should_show_intro";

  static const String INSUFFICIENT_BALANCE = "Insufficient balance for making this order";
  static const String SHOULD_SHOW_UPDATE_DIALOG = "should_show_update_dialog";
  static const String CURRENT_VERSION_NAME = "current_version_name";
  static const String CURRENT_VERSION_CODE = "current_version_code";
  static const String DYNAMIC_REFERRAL_IMAGE = "dynamic_referral_image";
  static const String DYNAMIC_REFERRAL_TITLE = "dynamic_referral_title";
  static const String DYNAMIC_SPLASH_IMAGE = "dynamic_splash_image";
  static const String DYNAMIC_SPLASH_TITLE = "dynamic_splash_title";

}