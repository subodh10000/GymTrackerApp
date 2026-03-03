# Privacy Policy URL Setup Guide

## Why This Is Critical

Apple **requires** a privacy policy URL for apps that collect user data. Your app collects:
- Personal information (name, age, gender, height, weight)
- Fitness preferences and goals
- Workout history and records

**Without a valid privacy policy URL, your app WILL be rejected.**

## What Apple Checks

1. ✅ **URL is accessible** - Must open in a browser without login
2. ✅ **URL is not a placeholder** - Cannot be "yourwebsite.com" or similar
3. ✅ **Content is relevant** - Should describe your app's data practices
4. ✅ **HTTPS preferred** - More secure, but HTTP is acceptable

## Step-by-Step: Host Your Privacy Policy

### Option 1: GitHub Pages (FREE - Recommended)

**Best for:** Quick setup, free hosting, professional URL

#### Steps:

1. **Create a GitHub account** (if you don't have one)
   - Go to https://github.com
   - Sign up for free

2. **Create a new repository**
   - Click "New repository"
   - Name it: `gymtracker-privacy-policy` (or any name)
   - Make it **Public**
   - Don't initialize with README
   - Click "Create repository"

3. **Create the privacy policy file**
   - In your repository, click "Add file" → "Create new file"
   - Name it: `privacy-policy.html` (or `index.html`)
   - Copy content from `PRIVACY_POLICY_HTML.html` in your project
   - Replace placeholders:
     - `[DATE]` → Today's date (e.g., "January 15, 2025")
     - `[YOUR_EMAIL_ADDRESS]` → Your contact email
     - `[YOUR_WEBSITE_URL]` → Your website (or remove if none)
   - Click "Commit new file"

4. **Enable GitHub Pages**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Under "Source", select "Deploy from a branch"
   - Select "main" branch and "/ (root)" folder
   - Click "Save"
   - Wait 1-2 minutes for deployment

5. **Get your URL**
   - Your privacy policy will be at:
     `https://YOUR_USERNAME.github.io/gymtracker-privacy-policy/privacy-policy.html`
   - Or if you named it `index.html`:
     `https://YOUR_USERNAME.github.io/gymtracker-privacy-policy/`

6. **Test the URL**
   - Open the URL in a browser
   - Make sure it loads correctly
   - Verify all content is visible

7. **Update Info.plist**
   - Open `Info.plist` in Xcode
   - Find line 8: `<string>https://yourwebsite.com/privacy-policy</string>`
   - Replace with your GitHub Pages URL
   - Save and commit

**Example URL:** `https://subodhkathayat.github.io/gymtracker-privacy-policy/privacy-policy.html`

---

### Option 2: Your Own Website

**Best for:** If you already have a website

#### Steps:

1. **Create privacy policy page**
   - Use content from `PRIVACY_POLICY_TEMPLATE.md`
   - Replace all placeholders
   - Save as HTML or markdown (depending on your site)

2. **Upload to your website**
   - Upload to your web server
   - Place at: `https://yourdomain.com/privacy-policy` or `https://yourdomain.com/privacy-policy.html`

3. **Test the URL**
   - Open in browser
   - Verify it's accessible

4. **Update Info.plist**
   - Replace placeholder URL with your actual URL

---

### Option 3: Other Free Hosting Services

**Alternatives:**
- **Netlify** - Free static site hosting
- **Vercel** - Free hosting with custom domains
- **GitLab Pages** - Similar to GitHub Pages
- **Notion** - Can publish pages publicly (less professional)

---

## Privacy Policy Content Requirements

Your privacy policy should include:

1. ✅ **What data you collect** (name, age, gender, etc.)
2. ✅ **How you use the data** (generate workout plans)
3. ✅ **Where data is stored** (locally on device)
4. ✅ **Third-party services** (your backend API)
5. ✅ **User rights** (how to delete data)
6. ✅ **Contact information** (your email)
7. ✅ **Last updated date**

**Your template already covers all of this!** Just replace the placeholders.

---

## Quick Checklist

Before submitting to App Store:

- [ ] Privacy policy is hosted on a real URL
- [ ] URL is publicly accessible (no login required)
- [ ] All placeholders are replaced:
  - [ ] `[DATE]` → Current date
  - [ ] `[YOUR_EMAIL_ADDRESS]` → Your email
  - [ ] `[YOUR_WEBSITE_URL]` → Your website or removed
- [ ] URL is tested in a browser
- [ ] `Info.plist` is updated with the real URL
- [ ] Privacy policy content matches your app's data practices

---

## Example: Complete Workflow

1. **Create GitHub repository** → `gymtracker-privacy-policy`
2. **Add file** → `privacy-policy.html` (with your content)
3. **Enable GitHub Pages** → Settings → Pages → Deploy from main branch
4. **Wait 2 minutes** → GitHub deploys your site
5. **Test URL** → `https://yourusername.github.io/gymtracker-privacy-policy/privacy-policy.html`
6. **Update Info.plist** → Replace placeholder with real URL
7. **Test in app** → Verify URL opens correctly

---

## Common Mistakes to Avoid

❌ **Using placeholder URL** - `yourwebsite.com` will be rejected
❌ **Private repository** - GitHub Pages requires public repo
❌ **Wrong file name** - Must be `index.html` or linked correctly
❌ **Not replacing placeholders** - Reviewers check content
❌ **Broken link** - Test the URL before submitting
❌ **Forgetting to update Info.plist** - Double-check the URL

---

## Testing Your Privacy Policy URL

Before submitting:

1. **Open URL in incognito/private browser**
   - Simulates what Apple reviewers see
   - No login should be required

2. **Check on mobile device**
   - Open URL on iPhone
   - Verify it loads correctly

3. **Verify content**
   - All sections are visible
   - No placeholder text remains
   - Contact email is valid

4. **Test from different locations**
   - Use a VPN or ask someone else to check
   - Ensures it's globally accessible

---

## What Happens During Review

1. **Apple reviewer opens your app**
2. **Checks Info.plist** for privacy policy URL
3. **Clicks the URL** (or copies it to browser)
4. **Verifies it loads** and is accessible
5. **Reviews content** to ensure it matches your app

**If any step fails → Rejection**

---

## After Submission

- ✅ Keep the URL active (don't delete the repository)
- ✅ Update the policy if your data practices change
- ✅ Update the "Last Updated" date when you make changes

---

## Need Help?

If you get stuck:
1. Check GitHub Pages documentation
2. Verify your repository is public
3. Check repository Settings → Pages for deployment status
4. Wait a few minutes after enabling Pages (deployment takes time)

---

## Summary

**Time Required:** 10-15 minutes
**Cost:** FREE (with GitHub Pages)
**Difficulty:** Easy

**Steps:**
1. Create GitHub repo
2. Add privacy policy HTML file
3. Enable GitHub Pages
4. Update Info.plist
5. Test URL

**That's it!** Your app will then meet Apple's privacy policy requirement.

