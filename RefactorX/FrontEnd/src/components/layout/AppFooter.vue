<template>
  <footer class="app-footer">
    <div class="footer-watermark">
      <img src="/img/GDL_LACIUDAD.png" alt="Guadalajara" class="watermark-logo" />
    </div>
    <div class="footer-content">
      <p>&copy; 2025 Municipio de Guadalajara - RefactorX Sistema de Gestion Administrativa</p>
    </div>
  </footer>
</template>

<script setup>
</script>

<style scoped>
.app-footer {
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  padding: 1rem 2rem;
  position: relative;
}

.footer-watermark {
  position: fixed;
  bottom: 60px;
  right: 20px;
  opacity: 0.15;
  pointer-events: none;
  z-index: 10;
}

.watermark-logo {
  height: 45px;
  width: auto;
}

.footer-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.footer-content p {
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.85rem;
  margin: 0;
}
</style>
