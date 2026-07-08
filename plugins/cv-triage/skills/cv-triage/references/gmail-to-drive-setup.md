# Getting attached CVs where the skill can read them

The Gmail connector returns email text, and in some setups **may not surface file attachments**. In case a CV attachment isn't readable directly from the email, it can arrive in a **CV source folder** the skill checks. Two options.

## Option A — Gmail → Drive auto-save (recommended; least-privilege version)

A small Google Apps Script copies attachments from your intake label into one Drive folder. The skill (which already has the Drive connector) reads CVs from there, matching them to candidates by the sender encoded in the filename.

This version requests only **two narrow permissions**:
- **Gmail: read-only** (`gmail.readonly`) — it can read mail but never modify, label, or delete it.
- **Drive: only-its-own-files** (`drive.file`) — it can only ever touch the CV folder it creates; it cannot see the rest of your Drive.

There is no Google scope for "one label only" (read-only is the floor) or "one named folder only" (`drive.file` is the floor) — these two are the narrowest grants that exist for a standalone script.

### Steps

1. Go to https://script.google.com → **New project**.
2. Open **Project Settings** (the gear icon, left) and tick **"Show 'appsscript.json' manifest file in editor."**
3. Back in the **Editor** (the `< >` icon), add the Drive advanced service: click **Services** ( **+** next to it) → choose **Drive API** → set **version v3** → **Add**.
4. Click on **`appsscript.json`** in the file list and replace its contents with the **Manifest** below. (Set the timezone if you want.)
5. Click on **`Code.gs`** and replace its contents with the **Script** below. Set `LABEL` and `FOLDER_NAME` at the top.
6. Click **Save**, then **Run**. Authorize when prompted — the consent screen should now show only:
   - *"View your email messages and settings"* (read-only Gmail), and
   - *"See, edit, create, and delete only the specific Google Drive files that you use with this app"* (the `drive.file` per-file scope).
   If you see broader items than these, the manifest or services step didn't take — redo 3–4.
   (You may see an "unverified app" notice for your own script: **Advanced → Go to project (unsafe)** — it's your own code.)
7. Check Drive: a folder named by `FOLDER_NAME` now holds the attachments.
8. Automate it: **Triggers** (clock icon) → **Add Trigger** → function `saveApplicationAttachmentsToDrive`, **Time-driven**, e.g. every hour. Save.
9. In the skill's setup, give that Drive folder as your **CV source**.

### Manifest (`appsscript.json`)

```json
{
  "timeZone": "Asia/Jerusalem",
  "runtimeVersion": "V8",
  "dependencies": {
    "enabledAdvancedServices": [
      { "userSymbol": "Drive", "version": "v3", "serviceId": "drive" }
    ]
  },
  "oauthScopes": [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/drive.file"
  ]
}
```

### Script (`Code.gs`)

```javascript
// Saves attachments from a Gmail label into one Drive folder.
// Permissions: gmail.readonly + drive.file only.
// No Gmail writes: processed messages are remembered in Script Properties.

var LABEL = 'job-applications';            // your intake label
var FOLDER_NAME = 'Application CVs';  // Drive folder this app creates and owns

function saveApplicationAttachmentsToDrive() {
  var props = PropertiesService.getScriptProperties();
  var folderId = getOrCreateFolderId_(props);

  var seen = JSON.parse(props.getProperty('seenMsgIds') || '[]');
  var seenSet = {};
  for (var i = 0; i < seen.length; i++) seenSet[seen[i]] = true;

  var label = GmailApp.getUserLabelByName(LABEL);  // read-only
  if (!label) { Logger.log('Label not found: ' + LABEL); return; }

  var threads = label.getThreads(0, 100);          // 100 most recent threads
  for (var t = 0; t < threads.length; t++) {
    var msgs = threads[t].getMessages();
    for (var m = 0; m < msgs.length; m++) {
      var msg = msgs[m];
      var id = msg.getId();
      if (seenSet[id]) continue;                    // already handled
      var from = msg.getFrom().replace(/[^\w.@-]/g, '_');
      var atts = msg.getAttachments();
      for (var a = 0; a < atts.length; a++) {
        var ct = atts[a].getContentType() || '';
        if (ct.indexOf('pdf') > -1 || ct.indexOf('word') > -1 ||
            ct.indexOf('officedocument') > -1 || ct.indexOf('image') > -1) {
          Drive.Files.create(
            { name: from + '__' + atts[a].getName(), parents: [folderId] },
            atts[a].copyBlob()
          );
        }
      }
      seen.push(id);
      seenSet[id] = true;
    }
  }
  // keep the most recent ~400 ids (Script Properties value limit is 9KB)
  props.setProperty('seenMsgIds', JSON.stringify(seen.slice(-400)));
}

function getOrCreateFolderId_(props) {
  var id = props.getProperty('folderId');
  if (id) return id;
  var folder = Drive.Files.create({
    name: FOLDER_NAME,
    mimeType: 'application/vnd.google-apps.folder'
  });
  props.setProperty('folderId', folder.id);
  return folder.id;
}
```

The filename prefix (`sender__originalname.pdf`) is what lets the skill match a saved CV to the right candidate. Processed-message memory keeps it from re-copying the same mail. (If the version 3 Drive service isn't offered in step 3 and you only get **v2**, change the two `Drive.Files.create(...)` calls to `Drive.Files.insert(...)` — same arguments.)

## Option B — local drop folder (zero setup, no script, no permissions)

Create `cvs/incoming/` in the working folder and drop attachment files there (name them with the candidate's name or email so the skill can match). Give that path as your **CV source**. Fine for low volume; at several applications a day, Option A is worth it. This grants no Gmail or Drive permissions at all.

## What the skill does either way

On each run it checks the CV source for files matching candidates. A candidate whose CV is attached-only and not yet present is parked as **Blocked** (kept out of the main decision list) with a one-line recovery note, and is picked up automatically once the file lands. Blocked candidates auto-lapse after 7 days if nothing arrives.
