import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // เพิ่มบรรทัดนี้เพื่อป้องกันการดันหน้าจอจนเพี้ยนเมื่อคีย์บอร์ดขึ้น
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          // แก้ Overflow โดยการทำให้เลื่อนได้
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 340,
            // เอา height: 620 ออก เพื่อให้กล่องยืดตามเนื้อหา ลดปัญหา Overflow
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 249, 248, 246),
              borderRadius: BorderRadius.circular(
                20,
              ), // ปรับให้โค้งมนขึ้นตามรูป
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // เงาจางๆ จะดูสวยกว่า
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // ให้ Column ใช้พื้นที่เท่าที่จำเป็น
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel("Email"),
                  _buildInputBox(hint: 'Enter your email', isPassword: false),

                  const SizedBox(height: 15),
                  _buildLabel("Password"),
                  _buildInputBox(hint: 'Enter your password', isPassword: true),

                  const SizedBox(height: 15),
                  _buildLabel("Confirm Password"),
                  _buildInputBox(
                    hint: 'Confirm your password',
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  // ปุ่ม Sign Up
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4332),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 25),
                  _buildDivider(), // เส้นแบ่ง OR
                  const SizedBox(height: 25),

                  // ปุ่ม Google
                  _buildGoogleButton(),

                  const SizedBox(height: 30),
                  _buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันย่อยสำหรับ Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // เส้นแบ่ง OR
  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("OR", style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  // ปุ่ม Google
  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
        height: 20,
      ),
      label: const Text(
        "Sign up with google",
        style: TextStyle(color: Colors.black),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  // ลิงก์ไปหน้า Login
  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),

        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            "Log in here!",
            style: TextStyle(
              color: Color(0xFF1B4332),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget สำหรับช่องกรอกข้อมูล
Widget _buildInputBox({required String hint, bool isPassword = false}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      obscureText: isPassword,
      // แก้ไขเรื่องคีย์บอร์ดที่นี่
      keyboardType: isPassword
          ? TextInputType.text
          : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: InputBorder.none,
      ),
    ),
  );
}
