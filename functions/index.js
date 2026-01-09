const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnInteraction = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    const postId = context.params.postId;
    const postOwnerId = newData.userId;

    // Detect new like
    if ((newData.likeCount || 0) > (oldData.likeCount || 0)) {
      await admin.messaging().sendToUserId(postOwnerId, {
        notification: {
          title: 'Someone liked your workout 💚',
          body: 'Your peaceful workout post got a like!',
        },
      });
      return;
    }
  });

exports.sendNotificationOnComment = functions.firestore
  .document('posts/{postId}/comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const postId = context.params.postId;

    const postSnap = await admin.firestore().collection('posts').doc(postId).get();
    if (!postSnap.exists) return;

    const post = postSnap.data();
    if (comment.userId === post.userId) return; // Don't notify self

    await admin.messaging().sendToUserId(post.userId, {
      notification: {
        title: 'New comment on your workout 🌿',
        body: `${comment.userName || 'Someone'} said: "${comment.text}"`,
      },
    });
  });