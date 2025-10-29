<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="parking" /></div>
      <div class="module-view-info">
        <h1>Estacionamientos Públicos</h1>
        <p>Menú principal del módulo</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="button-group">
            <router-link class="btn-municipal-primary" to="/estacionamiento-publico/consulta">
              <font-awesome-icon icon="search" /> Consulta
            </router-link>
            <router-link class="btn-municipal-secondary" to="/estacionamiento-publico/transacciones">
              <font-awesome-icon icon="plus" /> Transacciones
            </router-link>
            <router-link class="btn-municipal-secondary" to="/estacionamiento-publico/actualizacion">
              <font-awesome-icon icon="edit" /> Actualización
            </router-link>
            <router-link class="btn-municipal-secondary" to="/estacionamiento-publico/nuevo">
              <font-awesome-icon icon="file" /> Nuevo
            </router-link>
            <router-link class="btn-municipal-secondary" to="/estacionamiento-publico/reportes">
              <font-awesome-icon icon="list" /> Reportes
            </router-link>
          </div>
          <p class="text-muted" style="margin-top: 12px;">Selecciona una opción para continuar.</p>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
// Índice de estacionamiento_publico
</script>
