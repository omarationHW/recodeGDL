<template>
  <div class="busqueda-actividad-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de Actividad</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header text-center">
        <h5>BÚSQUEDA DE ACTIVIDADES</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent>
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="actividad" class="form-label">Actividad</label>
            </div>
            <div class="col-md-10">
              <input
                id="actividad"
                v-model="descripcion"
                @input="buscarActividades"
                class="form-control text-uppercase"
                type="text"
                placeholder="Ingrese descripción de la actividad"
                autocomplete="off"
                maxlength="255"
              />
            </div>
          </div>
        </form>
        <div class="table-responsive" style="max-height: 400px;">
          <table class="table table-bordered table-hover">
            <thead class="table-light">
              <tr>
                <th style="width: 80px;">SCIAN</th>
                <th>Descripción</th>
                <th style="width: 100px;">Costo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="actividad in actividades" :key="actividad.id_giro" @click="seleccionarActividad(actividad)" :class="{'table-active': actividad.id_giro === actividadSeleccionada?.id_giro}" style="cursor:pointer;">
                <td>{{ actividad.cod_giro }}</td>
                <td>{{ actividad.descripcion }}</td>
                <td>{{ actividad.costo ? '$' + actividad.costo : '' }}</td>
              </tr>
              <tr v-if="actividades.length === 0">
                <td colspan="3" class="text-center">No se encontraron actividades.</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-end mt-3">
          <button class="btn btn-primary" :disabled="!actividadSeleccionada" @click="aceptar">Aceptar</button>
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
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

<style scoped>
.busqueda-actividad-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.table-hover tbody tr:hover {
  background-color: #f5f5f5;
}
.table-active {
  background-color: #d0ebff !important;
}
</style>
