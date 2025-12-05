<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Sistema de Multas y Reglamentos</h1>
        <p>Bienvenido al módulo de gestión</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Mensaje de bienvenida -->
      <div class="municipal-card splash-card">
        <div class="municipal-card-body text-center">
          <div class="splash-icon">
            <font-awesome-icon icon="gavel" size="4x" />
          </div>
          <h2 class="splash-title">Módulo de Multas y Reglamentos</h2>
          <p class="splash-description">
            Sistema integral para la gestión de multas, sanciones y cumplimiento de reglamentos municipales
          </p>
        </div>
      </div>

      <!-- Características principales -->
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="file-invoice-dollar" size="2x" />
          </div>
          <h3>Gestión de Multas</h3>
          <p>Registro y seguimiento de multas administrativas</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="calculator" size="2x" />
          </div>
          <h3>Cálculos</h3>
          <p>Cálculo automático de recargos y descuentos</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="chart-line" size="2x" />
          </div>
          <h3>Reportes</h3>
          <p>Generación de reportes y estadísticas</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="search" size="2x" />
          </div>
          <h3>Consultas</h3>
          <p>Búsqueda avanzada de registros</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="hand-holding-dollar" size="2x" />
          </div>
          <h3>Pagos</h3>
          <p>Registro y control de pagos</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="users" size="2x" />
          </div>
          <h3>Contribuyentes</h3>
          <p>Gestión de padrones y contribuyentes</p>
        </div>
      </div>

      <!-- Información adicional -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>📋 Información del Sistema</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Versión:</strong>
              <span>2.0</span>
            </div>
            <div class="info-item">
              <strong>Módulo:</strong>
              <span>Multas y Reglamentos</span>
            </div>
            <div class="info-item">
              <strong>Estado:</strong>
              <span class="badge-success">Activo</span>
            </div>
            <div class="info-item">
              <strong>Última actualización:</strong>
              <span>{{ currentDate }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Acciones rápidas -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>⚡ Acciones Rápidas</h5>
        </div>
        <div class="municipal-card-body">
          <div class="quick-actions">
            <button class="action-btn" @click="navigateTo('busque')">
              <font-awesome-icon icon="search" />
              <span>Buscar Registros</span>
            </button>
            <button class="action-btn" @click="navigateTo('pruebacalcas')">
              <font-awesome-icon icon="calculator" />
              <span>Calculadora</span>
            </button>
            <button class="action-btn" @click="navigateTo('proyecfrm')">
              <font-awesome-icon icon="diagram-project" />
              <span>Proyectos</span>
            </button>
            <button class="action-btn" @click="navigateTo('Propuestatab')">
              <font-awesome-icon icon="table" />
              <span>Propuestas</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const currentDate = computed(() => {
  return new Date().toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

function navigateTo(module) {
  router.push(`/multas_reglamentos/${module}`)
}
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.text-center {
  text-align: center;
}

.splash-card {
  margin-bottom: 30px;
}

.splash-icon {
  color: #ea8215;
  margin-bottom: 20px;
}

.splash-title {
  color: #333;
  margin-bottom: 15px;
  font-size: 2rem;
  font-weight: 700;
}

.splash-description {
  color: #666;
  font-size: 1.1rem;
  max-width: 600px;
  margin: 0 auto;
  line-height: 1.6;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.feature-card {
  background: white;
  border-radius: 8px;
  padding: 25px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  text-align: center;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(234, 130, 21, 0.2);
  border-color: #ea8215;
}

.feature-icon {
  color: #ea8215;
  margin-bottom: 15px;
}

.feature-card h3 {
  color: #333;
  margin-bottom: 10px;
  font-size: 1.2rem;
}

.feature-card p {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.5;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.info-item strong {
  color: #333;
  font-size: 0.9rem;
}

.info-item span {
  color: #666;
  font-size: 1rem;
}

.badge-success {
  display: inline-block;
  padding: 4px 12px;
  background: #28a745;
  color: white;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 600;
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 15px 20px;
  background: white;
  border: 2px solid #ea8215;
  border-radius: 8px;
  color: #ea8215;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  font-size: 1rem;
}

.action-btn:hover {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(234, 130, 21, 0.3);
}

.action-btn svg {
  font-size: 1.2rem;
}

@media (max-width: 768px) {
  .splash-title {
    font-size: 1.5rem;
  }

  .splash-description {
    font-size: 1rem;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .quick-actions {
    grid-template-columns: 1fr;
  }
}
</style>
