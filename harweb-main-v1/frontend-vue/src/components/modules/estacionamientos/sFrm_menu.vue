<template>
  <div class="container-fluid mt-4">
    <div class="alert alert-info" role="alert">
      <h4 class="alert-heading">🅿️ Sistema  Frm menu</h4>
      <p>Este componente está en desarrollo y será implementado próximamente.</p>
      <hr>
      <p class="mb-0">
        <small><strong>Módulo:</strong> Estacionamientos | <strong>Componente:</strong> sFrm_menu</small>
      </p>
    </div>
    
    <div class="card">
      <div class="card-header bg-light">
        <h5 class="mb-0">Sistema  Frm menu</h5>
      </div>
      <div class="card-body">
        <p class="text-muted">
          Funcionalidad pendiente de implementación para el sistema de estacionamientos.
        </p>
        <div class="d-flex justify-content-between align-items-center">
          <span class="badge bg-warning">En desarrollo</span>
          <small class="text-muted">Módulo: Estacionamientos</small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'sFrm_menu',
  data() {
    return {
      // Datos del componente
    }
  },
  mounted() {
    console.log('Componente sFrm_menu montado (placeholder)');
  }
}
</script>

<style scoped>
.alert-heading {
  color: #0c5460;
}

.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.badge {
  font-size: 0.75em;
}
</style>
