<template>
  <div class="municipal-form-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de Actividad</li>
      </ol>
    </nav>
    <div class="municipal-header">
      <i class="fas fa-search text-white me-2"></i>
      <h2>BÚSQUEDA DE ACTIVIDADES</h2>
    </div>
    <div class="municipal-card">
      <div class="municipal-card-body">
        <form @submit.prevent class="mb-4">
          <div class="row align-items-end">
            <div class="col-md-3">
              <label for="actividad" class="form-label">
                <i class="fas fa-tags me-2"></i>Actividad
              </label>
            </div>
            <div class="col-md-9">
              <input
                id="actividad"
                v-model="descripcion"
                @input="buscarActividades"
                class="form-control text-uppercase"
                type="text"
                placeholder="Ingrese descripción de la actividad..."
                autocomplete="off"
                maxlength="255"
              />
            </div>
          </div>
        </form>
        <div class="table-responsive" style="max-height: 400px;">
          <table class="table table-sm municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 80px;">SCIAN</th>
                <th>Descripción</th>
                <th style="width: 100px;">Costo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="actividad in actividades" :key="actividad.id_giro" @click="seleccionarActividad(actividad)" :class="{'municipal-selected': actividad.id_giro === actividadSeleccionada?.id_giro}" style="cursor:pointer;">
                <td><span class="badge bg-secondary">{{ actividad.cod_giro }}</span></td>
                <td>{{ actividad.descripcion }}</td>
                <td class="text-success fw-bold">{{ actividad.costo ? '$' + actividad.costo : '-' }}</td>
              </tr>
              <tr v-if="actividades.length === 0">
                <td colspan="3" class="text-center text-muted py-4">
                  <i class="fas fa-search me-2"></i>No se encontraron actividades.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-end mt-4">
          <div class="btn-group municipal-group-btn" role="group">
            <button class="btn btn-outline-primary" :disabled="!actividadSeleccionada" @click="aceptar">
              <i class="fas fa-check me-1"></i>Aceptar
            </button>
          </div>
        </div>
        <div v-if="error" class="alert alert-danger mt-3">
          <i class="fas fa-exclamation-triangle me-2"></i>{{ error }}
        </div>
      </div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaActividadPage',
  data() {
    return {
      descripcion: '',
      actividades: [],
      actividadSeleccionada: null,
      scian: '', // Este valor debe ser pasado por props, query o route param
      error: null
    };
  },
  mounted() {
    // Obtener el valor de scian desde query, props o route param
    this.scian = this.$route.query.scian || '';
    this.buscarActividades();
  },
  methods: {
    async buscarActividades() {
      if (!this.scian) {
        this.actividades = [];
        return;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'buscar_actividades',
            params: {
              scian: this.scian,
              descripcion: this.descripcion
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.actividades = data.eResponse.data;
        } else {
          this.actividades = [];
          this.error = data.eResponse.error || 'Error al buscar actividades';
        }
      } catch (err) {
        this.error = err.message;
      }
    },
    seleccionarActividad(actividad) {
      this.actividadSeleccionada = actividad;
    },
    aceptar() {
      if (this.actividadSeleccionada) {
        // Aquí puedes emitir un evento, navegar, o guardar la selección
        // Por ejemplo, emitir evento:
        this.$emit('actividad-seleccionada', this.actividadSeleccionada);
        // O navegar a otra página:
        // this.$router.push({ name: 'OtraPagina', params: { id_giro: this.actividadSeleccionada.id_giro } });
        alert('Actividad seleccionada: ' + this.actividadSeleccionada.descripcion);
      }
    }
  }
};
</script>

