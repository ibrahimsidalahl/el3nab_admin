import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handleDioError(DioException error) {
    // 1️⃣ Handle network timeouts
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return AppException(' انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى.⏱️');
    }
    // 2️⃣ Handle no internet
    if (error.type == DioExceptionType.connectionError) {
      return AppException(' لا يوجد اتصال بالإنترنت، تأكد من الشبكة.');
    }
    // 3️⃣ Handle server responses
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      // نجيب الرسالة الأصلية من السيرفر إن وجدت
      final messageFromServer = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'حدث خطأ من الخادم، يرجى المحاولة لاحقاً.';

      // 4️⃣ تحليل أنواع الأخطاء المعروفة
      switch (messageFromServer) {
        case 'Invalid password':
          return AppException(
            'كلمة المرور غير صحيحة 🔐',
            statusCode: statusCode,
          );

        case 'Invalid phone number':
          return AppException('رقم الهاتف غير صحيح 📱', statusCode: statusCode);
        case 'Multiple vendors are not allowed':
          return AppException('لا يمكن طلب أوردر من أكثر من متجر، يجب اختيار متجر واحد فقط.', statusCode: statusCode);

        case 'API Key is required':
          return AppException(
            'مفتاح الـ API مفقود 🔑، الرجاء إعادة المحاولة أو التواصل مع الدعم',
            statusCode: statusCode,
          );
        case 'This user is not allowed to login to this app.':
          return AppException(
            'الحساب غير مصرح له بالدخول لهذا التطبيق 🚫',
            statusCode: statusCode,
          );

        case 'Email already exists':
          return AppException(
            'هذا البريد الإلكتروني مسجل بالفعل 📧',
            statusCode: statusCode,
          );

        case 'Phone number already exists':
          return AppException(
            'رقم الهاتف مسجل مسبقًا 📲',
            statusCode: statusCode,
          );

        case 'User not found':
          return AppException('المستخدم غير موجود ', statusCode: statusCode);
        case 'New password cannot be the same as the old password':
          return AppException(
            'كلمة المرور الجديدة يجب أن تكون مختلفة عن القديمة. ',
            statusCode: statusCode,
          );

        case 'Invalid token':
          return AppException(
            'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجددًا 🔑',
            statusCode: statusCode,
          );
        case 'User not authenticated.':
          return AppException(
            'تم فقد الاتصال بحسابك، يرجى تسجيل الدخول مجددًا. ',
            statusCode: statusCode,
          );

        case 'Missing token':
          return AppException(
            'لم يتم العثور على رمز التحقق 🔒',
            statusCode: statusCode,
          );
        case 'Invalid OTP':
          return AppException(
            'رمز التحقق غير صحيح ، يرجى المحاولة مرة أخرى.',
            statusCode: statusCode,
          );
        case 'Phone number is not verified':
          return AppException(
            'رقم الهاتف غير مفعّل، يرجى تأكيد رقم الهاتف.',
            statusCode: statusCode,
            isPhoneNotVerified: true,
          );
        default:
          // لو رسالة السيرفر غير متوقعة
          return AppException(messageFromServer, statusCode: statusCode);
      }
    }
    // 5️⃣ Unknown error fallback
    return AppException('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى ⚠️');
  }
}
