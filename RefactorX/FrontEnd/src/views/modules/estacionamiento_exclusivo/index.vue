<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="parking" /></div>
      <div class="module-view-info">
        <h1>Estacionamiento Exclusivo</h1>
        <p>Gestión de estacionamientos exclusivos y apremios</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Operaciones Principales</h5>
        </div>
        <div class="municipal-card-body">
          <div class="button-grid">
            <router-link :to="{ name: 'estacionamiento-exclusivo-expedientes' }" class="btn-municipal-primary">
              <font-awesome-icon icon="folder-open" />
              Expedientes
            </router-link>
            <router-link :to="{ name: 'estacionamiento-exclusivo-notificaciones' }" class="btn-municipal-primary">
              <font-awesome-icon icon="bell" />
              Notificaciones
            </router-link>
            <router-link :to="{ name: 'estacionamiento-exclusivo-actuaciones' }" class="btn-municipal-primary">
              <font-awesome-icon icon="tasks" />
              Actuaciones
            </router-link>
            <router-link :to="{ name: 'estacionamiento-exclusivo-pagos' }" class="btn-municipal-primary">
              <font-awesome-icon icon="dollar-sign" />
              Pagos
            </router-link>
            <router-link :to="{ name: 'estacionamiento-exclusivo-reportes' }" class="btn-municipal-primary">
              <font-awesome-icon icon="chart-bar" />
              Reportes
            </router-link>
            <router-link :to="{ name: 'estacionamiento-exclusivo-fases' }" class="btn-municipal-primary">
              <font-awesome-icon icon="stream" />
              Control de Fases
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// Índice del módulo Estacionamiento Exclusivo
</script>


