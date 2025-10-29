<template>
  <div class="menu-cementerios-container">
    <div class="menu-header">
      <h1 class="menu-title">
        <i class="fas fa-cross"></i>
        Módulo de Cementerios
      </h1>
      <p class="menu-subtitle">Sistema Municipal de Gestión de Cementerios</p>
    </div>

    <div class="menu-categories">
      <!-- Gestión de Datos -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-database"></i>
          Gestión de Datos
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/abcementer" class="menu-item">
            <i class="fas fa-church"></i>
            <span>ABC Cementerios</span>
          </router-link>
          <router-link to="/cementerios/abcfolio" class="menu-item">
            <i class="fas fa-folder-open"></i>
            <span>ABC Folios</span>
          </router-link>
          <router-link to="/cementerios/abcpagos" class="menu-item">
            <i class="fas fa-dollar-sign"></i>
            <span>ABC Pagos</span>
          </router-link>
          <router-link to="/cementerios/abcrecargos" class="menu-item">
            <i class="fas fa-plus-circle"></i>
            <span>ABC Recargos</span>
          </router-link>
        </div>
      </div>

      <!-- Consultas -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-search"></i>
          Consultas
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/consultafol" class="menu-item">
            <i class="fas fa-file-alt"></i>
            <span>Consulta por Folio</span>
          </router-link>
          <router-link to="/cementerios/consultarcm" class="menu-item">
            <i class="fas fa-search-location"></i>
            <span>Consulta RCM</span>
          </router-link>
          <router-link to="/cementerios/consultanombre" class="menu-item">
            <i class="fas fa-user-search"></i>
            <span>Consulta por Nombre</span>
          </router-link>
          <router-link to="/cementerios/conindividual" class="menu-item">
            <i class="fas fa-user-circle"></i>
            <span>Consulta Individual</span>
          </router-link>
        </div>
      </div>

      <!-- Consultas por Cementerio -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-map-marker-alt"></i>
          Consultas por Cementerio
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/consultaguad" class="menu-item">
            <i class="fas fa-cross"></i>
            <span>Guadalajara</span>
          </router-link>
          <router-link to="/cementerios/consultajardin" class="menu-item">
            <i class="fas fa-leaf"></i>
            <span>Jardín</span>
          </router-link>
          <router-link to="/cementerios/consultamezq" class="menu-item">
            <i class="fas fa-church"></i>
            <span>Mezquitán</span>
          </router-link>
          <router-link to="/cementerios/consultasandres" class="menu-item">
            <i class="fas fa-monument"></i>
            <span>San Andrés</span>
          </router-link>
        </div>
      </div>

      <!-- Operaciones Especiales -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-cogs"></i>
          Operaciones Especiales
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/bonificaciones" class="menu-item">
            <i class="fas fa-percentage"></i>
            <span>Bonificaciones</span>
          </router-link>
          <router-link to="/cementerios/descuentos" class="menu-item">
            <i class="fas fa-tags"></i>
            <span>Descuentos</span>
          </router-link>
          <router-link to="/cementerios/duplicados" class="menu-item">
            <i class="fas fa-copy"></i>
            <span>Duplicados</span>
          </router-link>
          <router-link to="/cementerios/traslados" class="menu-item">
            <i class="fas fa-arrows-alt"></i>
            <span>Traslados</span>
          </router-link>
        </div>
      </div>

      <!-- Títulos y Liquidaciones -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-file-contract"></i>
          Títulos y Liquidaciones
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/titulos" class="menu-item">
            <i class="fas fa-certificate"></i>
            <span>Títulos</span>
          </router-link>
          <router-link to="/cementerios/titulossin" class="menu-item">
            <i class="fas fa-file-signature"></i>
            <span>Generar Títulos</span>
          </router-link>
          <router-link to="/cementerios/liquidaciones" class="menu-item">
            <i class="fas fa-calculator"></i>
            <span>Liquidaciones</span>
          </router-link>
        </div>
      </div>

      <!-- Reportes y Estadísticas -->
      <div class="menu-category">
        <h3 class="category-title">
          <i class="fas fa-chart-bar"></i>
          Reportes y Estadísticas
        </h3>
        <div class="menu-grid">
          <router-link to="/cementerios/estad-adeudo" class="menu-item">
            <i class="fas fa-chart-line"></i>
            <span>Estadísticas Adeudos</span>
          </router-link>
          <router-link to="/cementerios/rep-a-cobrar" class="menu-item">
            <i class="fas fa-file-invoice-dollar"></i>
            <span>Cuentas por Cobrar</span>
          </router-link>
          <router-link to="/cementerios/rep-bon" class="menu-item">
            <i class="fas fa-percent"></i>
            <span>Reporte Bonificaciones</span>
          </router-link>
          <router-link to="/cementerios/rpttitulos" class="menu-item">
            <i class="fas fa-file-pdf"></i>
            <span>Reporte Títulos</span>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'

onMounted(() => {
  console.log('Menú de Cementerios cargado')
})
</script>

<style scoped>
.menu-cementerios-container {
  padding: 2rem;
  max-width: 1400px;
  margin: 0 auto;
}

.menu-header {
  text-align: center;
  margin-bottom: 3rem;
  padding-bottom: 2rem;
  border-bottom: 3px solid var(--color-primary);
}

.menu-title {
  font-size: 2.5rem;
  color: var(--color-primary);
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.menu-subtitle {
  font-size: 1.125rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.menu-categories {
  display: flex;
  flex-direction: column;
  gap: 2.5rem;
}

.menu-category {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.category-title {
  font-size: 1.25rem;
  color: var(--color-primary);
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid var(--color-bg-secondary);
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.menu-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  padding: 1.5rem 1rem;
  background: var(--color-bg-secondary);
  border-radius: 0.5rem;
  text-decoration: none;
  color: var(--color-text-primary);
  transition: all 0.3s ease;
  border: 2px solid transparent;
  text-align: center;
}

.menu-item:hover {
  background: var(--color-primary);
  color: white;
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(33, 87, 155, 0.3);
  border-color: var(--color-primary);
}

.menu-item i {
  font-size: 2rem;
  opacity: 0.8;
}

.menu-item span {
  font-size: 0.95rem;
  font-weight: 600;
}

@media (max-width: 768px) {
  .menu-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }

  .menu-title {
    font-size: 1.75rem;
  }

  .menu-item {
    padding: 1rem 0.75rem;
  }

  .menu-item i {
    font-size: 1.5rem;
  }
}
</style>
