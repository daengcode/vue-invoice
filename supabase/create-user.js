/**
 * Create Custom User Script
 * Uses custom users table instead of Supabase Auth
 *
 * Usage:
 * 1. Make sure .env is configured with your Supabase credentials
 * 2. Run: node supabase/create-user.js
 */

import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import readline from "readline";
import * as bcrypt from "bcryptjs";

dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error("❌ Error: Missing Supabase credentials in .env file");
  console.error("Make sure VITE_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set");
  console.error("\nTo get SUPABASE_SERVICE_ROLE_KEY:");
  console.error("1. Go to Supabase dashboard → Settings → API");
  console.error("2. Copy the 'Service Role' key");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function question(prompt) {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
}

async function createUser() {
  console.log("\n📝 Create Custom User for Invoice System\n");

  try {
    // Get user input
    const email =
      (await question("Email (default: admin@catering.test): ")) || "admin@catering.test";
    const password = (await question("Password (default: admin123): ")) || "admin123";
    const fullName = (await question("Full Name (default: Admin User): ")) || "Admin User";
    const role = (await question("Role (default: admin): ")) || "admin";

    console.log("\n⏳ Checking if user exists...");

    // Check if user already exists
    const { data: existingUser, error: checkError } = await supabase
      .from("users")
      .select("id, email")
      .eq("email", email)
      .maybeSingle();

    if (existingUser) {
      console.log("\n💡 User already exists. You can login with these credentials:");
      console.log(`   Email: ${email}`);
      console.log(`   Password: ${password}`);
      rl.close();
      return;
    }

    console.log("\n⏳ Creating user...");

    // Hash password with bcryptjs
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Insert user into custom users table
    const { data: newUser, error: insertError } = await supabase
      .from("users")
      .insert({
        email: email,
        password_hash: passwordHash,
        full_name: fullName,
        role: role,
        is_active: true,
      })
      .select()
      .single();

    if (insertError) {
      console.error("❌ Error creating user:", insertError.message);
      rl.close();
      return;
    }

    console.log("\n✅ User created successfully!");
    console.log("\n📋 Login Credentials:");
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   User ID: ${newUser.id}`);
    console.log(`   Full Name: ${newUser.full_name}`);
    console.log(`   Role: ${newUser.role}`);
    console.log(`   Active: ${newUser.is_active ? "Yes" : "No"}`);

    // Debug info
    console.log("\n🔍 Debug Info:");
    console.log(`   Password Hash: ${newUser.password_hash}`);
    console.log(`   Hash Length: ${newUser.password_hash.length}`);

    console.log("\n🚀 You can now login at: http://localhost:5173/login");
  } catch (error) {
    console.error("❌ Unexpected error:", error.message);
  } finally {
    rl.close();
  }
}

// Run the script
createUser();
