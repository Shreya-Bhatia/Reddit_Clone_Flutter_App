import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/models/chat_contact.dart';
import 'package:reddit/models/user_model.dart';

import '../../../core/type_defs.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider), 
    auth: ref.read(authProvider), 
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore, 
    required FirebaseAuth auth, 
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _contacts => _firestore.collection(FirebaseConstants.contactsCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle (bool isFromLogin) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken, 
      );

      UserCredential userCredential;
      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential = await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      ChatContact contact;

      if(userCredential.additionalUserInfo!.isNewUser)
      {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL??Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'til',
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
          ],
        );

        contact = ChatContact(
          id: userModel.uid,
          name: userModel.name,
          profilePic: userModel.profilePic,
          contacts: [],
        );

        await _users.doc(userModel.uid).set(userModel.toMap());
        await _contacts.doc(userModel.uid).set(contact.toMap());
      }
      else
      {
        userModel = await getUserData(userCredential.user!.uid).first;
        bool exist = false;
        await _contacts.doc(userModel.uid).get().then((value) {
          exist = value.exists;
        });
        if(exist) {
          contact = await getContactData(userCredential.user!.uid).first;
        } else {
          contact = ChatContact(
            id: userModel.uid,
            name: userModel.name,
            profilePic: userModel.profilePic,
            contacts: [],
          );
          await _contacts.doc(userModel.uid).set(contact.toMap());
        }
        
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest () async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );

      await _users.doc(userModel.uid).set(userModel.toMap());
      
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // to see real time updates happening we use stream..
  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<ChatContact> getContactData(String uid) {
    return _contacts.doc(uid).snapshots().map((event) => ChatContact.fromMap(event.data() as Map<String, dynamic>));
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}