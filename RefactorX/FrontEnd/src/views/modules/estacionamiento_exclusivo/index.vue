<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="gavel" /></div>
      <div class="module-view-info">
        <h1>Apremios SVN</h1>
        <p>Seleccione una operación del módulo</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <ul>
            <li><router-link :to="{ name: 'apremiossvn-expedientes' }">Expedientes</router-link></li>
            <li><router-link :to="{ name: 'apremiossvn-notificaciones' }">Notificaciones</router-link></li>
            <li><router-link :to="{ name: 'apremiossvn-actuaciones' }">Actuaciones</router-link></li>
            <li><router-link :to="{ name: 'apremiossvn-pagos' }">Pagos</router-link></li>
            <li><router-link :to="{ name: 'apremiossvn-reportes' }">Reportes</router-link></li>
            <li><router-link :to="{ name: 'apremiossvn-fases' }">Control de Fases</router-link></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Índice del módulo Apremios SVN
</script>

