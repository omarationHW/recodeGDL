<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cross" />
      </div>
      <div class="module-view-info">
        <h1>Módulo de Cementerios</h1>
        <p>Sistema de Gestión de Cementerios Municipales</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <h3>Bienvenido al Módulo de Cementerios</h3>
          <p>Desde este módulo puede administrar:</p>
          <ul>
            <li>Catálogo de Cementerios</li>
            <li>Gestión de Fosas</li>
            <li>Registro de Títulos</li>
            <li>Control de Pagos</li>
            <li>Reportes y Estadísticas</li>
          </ul>

          <div class="mt-4">
            <h4>Accesos Rápidos</h4>
            <div class="quick-links">
              <router-link to="/cementerios/abcementer" class="btn-municipal-primary">
                <font-awesome-icon icon="cross" />
                Catálogo de Cementerios
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
</script>
