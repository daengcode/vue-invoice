/**
 * Create Supabase Auth User Script
 *
 * Usage:
 * 1. Make sure .env is configured with your Supabase credentials
 * 2. Run: node supabase/create-user.js
 */

import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import readline from "readline";

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
  console.log("\n📝 Create Supabase Auth User for Invoice System\n");

  try {
    // Get user input
    const email =
      (await question("Email (default: admin@catering.test): ")) || "admin@catering.test";
    const password = (await question("Password (default: admin123): ")) || "admin123";
    const fullName = (await question("Full Name (default: Admin User): ")) || "Admin User";
    const role = (await question("Role (default: admin): ")) || "admin";

    console.log("\n⏳ Checking if user exists...");

    const { data: existingUsers, error: listError } = await supabase.auth.admin.listUsers();

    if (listError) {
      console.error("❌ Error checking users:", listError.message);
      rl.close();
      return;
    }

    const existingUser = existingUsers.users.find((user) => user.email === email);

    if (existingUser) {
      console.log("\n💡 User already exists. You can login with these credentials:");
      console.log(`   Email: ${email}`);
      console.log(`   Password: ${password}`);
      console.log(`   User ID: ${existingUser.id}`);
      rl.close();
      return;
    }

    console.log("\n⏳ Creating user...");

    const { data, error: createError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: fullName,
        role,
      },
    });

    if (createError) {
      console.error("❌ Error creating user:", createError.message);
      rl.close();
      return;
    }

    const newUser = data.user;

    console.log("\n✅ User created successfully!");
    console.log("\n📋 Login Credentials:");
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   User ID: ${newUser.id}`);
    console.log(`   Full Name: ${newUser.user_metadata.full_name}`);
    console.log(`   Role: ${newUser.user_metadata.role}`);

    console.log("\n🚀 You can now login at: http://localhost:5173/login");
  } catch (error) {
    console.error("❌ Unexpected error:", error.message);
  } finally {
    rl.close();
  }
}

// Run the script
createUser();
