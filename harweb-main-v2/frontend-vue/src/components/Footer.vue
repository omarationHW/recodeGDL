<template>
  <footer class="municipal-footer">
    <div class="footer-content">
      <!-- Logos oficiales -->
      <div class="footer-logos">
        <img 
          src="/img/GDL_LACIUDAD.png" 
          alt="Guadalajara - La Ciudad" 
          class="footer-logo"
        />
        <img 
          src="/img/Innovacion_Gubernamental.png" 
          alt="Innovación Gubernamental" 
          class="footer-logo"
        />
      </div>
      
      <!-- Información municipal -->
      <div class="footer-info">
        <p class="footer-text">
          Gobierno Municipal de Guadalajara, Jalisco
        </p>
        <p class="footer-year">
          {{ currentYear }}
        </p>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'Footer',
  computed: {
    currentYear() {
      return new Date().getFullYear();
    }
  }
}
</script>

<style scoped>
.municipal-footer {
  background: var(--municipal-primary);
  color: white;
  padding: 1rem;
  width: 100%;
  position: relative;
  z-index: 50;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.footer-logos {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 3rem;
  flex-wrap: wrap;
  margin: 0 auto;
}

.footer-logo {
  height: 40px;
  width: auto;
  object-fit: contain;
  object-position: center;
  filter: brightness(0) invert(1);
  transition: transform 0.2s ease;
  vertical-align: middle;
}

.footer-logo:hover {
  transform: scale(1.05);
}

.footer-info {
  text-align: center;
}

.footer-text {
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-regular);
  font-size: 1rem;
  margin: 0 0 0.5rem 0;
  opacity: 0.9;
}

.footer-year {
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-extralight);
  font-size: 0.875rem;
  margin: 0;
  opacity: 0.7;
}

/* Responsive */
@media (max-width: 768px) {
  .municipal-footer {
    padding: 0.75rem;
  }
  
  .footer-logos {
    gap: 1rem;
  }
  
  .footer-logo {
    height: 35px;
  }
  
  .footer-text {
    font-size: 0.875rem;
  }
}

@media (max-width: 480px) {
  .footer-logos {
    gap: 0.75rem;
  }
  
  .footer-logo {
    height: 30px;
  }
  
  .footer-text {
    font-size: 0.8rem;
  }
}
</style>