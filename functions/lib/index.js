"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFeed = exports.notificationHandler = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const notificationHandler_1 = require("./notificationHandler");
const getFeed_1 = require("./getFeed");
admin.initializeApp();
exports.notificationHandler = functions.firestore.document("/insta_a_feed/{userId}/items/{activityFeedItem}")
    .onCreate((snapshot, context) => __awaiter(void 0, void 0, void 0, function* () {
    yield notificationHandler_1.notificationHandlerModule(snapshot, context);
}));
exports.getFeed = functions.https.onRequest((req, res) => {
    getFeed_1.getFeedModule(req, res);
});
//# sourceMappingURL=index.js.map