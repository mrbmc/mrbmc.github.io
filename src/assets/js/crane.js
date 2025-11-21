import { CraneScene } from './modules/crane-scene.mjs';

// Initialize the crane scene when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('crane-canvas');
  
  if (canvas) {
    const craneScene = new CraneScene(canvas);
    craneScene.init();
    craneScene.animate();
  }
});

// // Clean up on page unload
// window.addEventListener('beforeunload', () => {
//   if (craneScene) {
//     craneScene.dispose();
//   }
// });
