<template>
  <div class="repestado-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Estado del Trámite</li>
      </ol>
    </nav>
    <h2>Reporte del Estado del Trámite</h2>
    <form @submit.prevent="buscarTramite">
      <div class="form-group row">
        <label for="id_tramite" class="col-sm-2 col-form-label">No. Trámite</label>
        <div class="col-sm-4">
          <input type="number" v-model="id_tramite" class="form-control" id="id_tramite" required />
        </div>
        <div class="col-sm-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="tramite" class="card mt-4">
      <div class="card-header">Datos del Trámite</div>
      <div class="card-body">
        <dl class="row">
          <dt class="col-sm-3">Folio</dt>
          <dd class="col-sm-9">{{ tramite.folio }}</dd>
          <dt class="col-sm-3">Fecha de Captura</dt>
          <dd class="col-sm-9">{{ tramite.feccap }}</dd>
          <dt class="col-sm-3">Solicitante</dt>
          <dd class="col-sm-9">{{ tramite.propietarionvo }}</dd>
          <dt class="col-sm-3">Actividad</dt>
          <dd class="col-sm-9">{{ tramite.actividad }}</dd>
          <dt class="col-sm-3">Giro</dt>
          <dd class="col-sm-9">{{ tramite.id_giro }}</dd>
          <dt class="col-sm-3">Dirección</dt>
          <dd class="col-sm-9">{{ tramite.ubicacion }} No. {{ tramite.numext_ubic }} {{ tramite.letraext_ubic }} Int. {{ tramite.numint_ubic }} {{ tramite.letraint_ubic }}</dd>
          <dt class="col-sm-3">Colonia</dt>
          <dd class="col-sm-9">{{ tramite.colonia_ubic }}</dd>
          <dt class="col-sm-3">Estatus</dt>
          <dd class="col-sm-9"><span :class="estatusClass(tramite.estatus)">{{ estatusLabel(tramite.estatus) }}</span></dd>
        </dl>
        <button class="btn btn-success" @click="imprimirReporte" :disabled="!tramite">Imprimir Reporte</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepEstadoPage',
  data() {
    return {
      id_tramite: '',
      tramite: null,
      loading: false,
      error: '',
    };
  },
  methods: {
    async buscarTramite() {
      this.error = '';
      this.tramite = null;
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'get_estado_tramite',
            params: { id_tramite: this.id_tramite }
          }
        });
        if (response.data.eResponse.success && response.data.eResponse.data.length > 0) {
          this.tramite = response.data.eResponse.data[0];
        } else {
          this.error = 'No se encontró el trámite.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || 'Error al consultar el trámite.';
      } finally {
        this.loading = false;
      }
    },
    async imprimirReporte() {
      if (!this.tramite) return;
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'print_reporte',
            params: { id_tramite: this.tramite.id_tramite }
          }
        });
        if (response.data.eResponse.success) {
          window.open(response.data.eResponse.data.pdf_url, '_blank');
        } else {
          this.error = response.data.eResponse.message || 'No se pudo imprimir el reporte.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || 'Error al imprimir el reporte.';
      } finally {
        this.loading = false;
      }
    },
    estatusLabel(val) {
      switch (val) {
        case 'A': return 'APROBADO';
        case 'P': return 'PENDIENTE';
        case 'C': return 'CANCELADO';
        case 'O': return 'CONDICIONADO';
        case 'N': return 'NO APROBADO';
        case 'V': return 'VIGENTE';
        default: return val;
      }
    },
    estatusClass(val) {
      switch (val) {
        case 'A': return 'badge badge-success';
        case 'P': return 'badge badge-warning';
        case 'C': return 'badge badge-danger';
        case 'O': return 'badge badge-info';
        case 'N': return 'badge badge-secondary';
        case 'V': return 'badge badge-primary';
        default: return 'badge badge-light';
      }
    }
  }
};
</script>

<style scoped>
.repestado-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.card {
  margin-top: 2rem;
}
.badge {
  font-size: 1em;
  padding: 0.3em 0.8em;
}
</style>
