// Export Active Storage's primitives without loading its browser-only UJS
// autostart. The native product component can import DirectUpload through a
// shared module graph, but uploads are only invoked in the browser.
export { DirectUpload } from "@rails/activestorage/src/direct_upload.js";
export { DirectUploadController } from "@rails/activestorage/src/direct_upload_controller.js";
export { DirectUploadsController } from "@rails/activestorage/src/direct_uploads_controller.js";
export { dispatchEvent } from "@rails/activestorage/src/helpers.js";

export const start = () => {};
