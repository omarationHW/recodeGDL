<template>
  <div class="container-fluid mt-4">
    <div class="card border-0 shadow-sm">
      <div class="card-body p-4">
        <div class="d-flex align-items-center mb-3">
          <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
            <i class="fas fa-sync-alt fa-2x text-secondary"></i>
          </div>
          <div>
            <h1 class="h3 fw-bold text-dark mb-1">GActualiza</h1>
            <p class="text-muted mb-0">Gestión de actualizaciones del sistema</p>
          </div>
        </div>

        <div class="alert alert-info">
          <div class="d-flex align-items-center">
            <i class="fas fa-info-circle me-2"></i>
            <div>
              <strong>Componente en desarrollo</strong>
              <p class="mb-0 small">Este componente está siendo modernizado como parte del sistema integral.</p>
            </div>
          </div>
        </div>

        <div class="row g-4">
          <div class="col-md-6">
            <div class="card border-secondary border-opacity-25">
              <div class="card-header bg-secondary bg-opacity-10">
                <h5 class="fw-bold mb-0 text-secondary">
                  <i class="fas fa-database me-2"></i>Actualización de Datos
                </h5>
              </div>
              <div class="card-body">
                <p class="text-muted mb-3">Funcionalidad para actualizar registros del sistema</p>
                <button class="btn btn-secondary" disabled>
                  <i class="fas fa-sync me-1"></i>Actualizar
                </button>
              </div>
            </div>
          </div>

          <div class="col-md-6">
            <div class="card border-info border-opacity-25">
              <div class="card-header bg-info bg-opacity-10">
                <h5 class="fw-bold mb-0 text-info">
                  <i class="fas fa-history me-2"></i>Historial
                </h5>
              </div>
              <div class="card-body">
                <p class="text-muted mb-3">Registro de actualizaciones realizadas</p>
                <button class="btn btn-info" disabled>
                  <i class="fas fa-list me-1"></i>Ver Historial
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GActualiza',
  data() {
    return {
      // Estado del componente
    }
  }
}
</script>

<style scoped>
.card {
  transition: transform 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
}
</style>