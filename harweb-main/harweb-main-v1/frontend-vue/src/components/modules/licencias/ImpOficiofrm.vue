<template>
  <div class="imp-oficio-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/tramites">Trámites</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Oficio Improcedente</li>
      </ol>
    </nav>
    <div class="card shadow">
      <div class="card-header bg-danger text-white">
        <h5>Trámite Improcedente</h5>
      </div>
      <div class="card-body">
        <p class="lead">
          Se encontró el trámite improcedente.<br>
          ¿Desea imprimir algún oficio?
        </p>
        <div class="mb-3">
          <label for="oficioType" class="form-label">Seleccione el tipo de oficio a imprimir:</label>
          <div>
            <div v-for="option in oficioOptions" :key="option.id" class="form-check form-check-inline">
              <input class="form-check-input" type="radio" :id="'oficio'+option.id" v-model="selectedOficio" :value="option.id">
              <label class="form-check-label" :for="'oficio'+option.id">{{ option.label }}</label>
            </div>
          </div>
        </div>
        <div class="mb-3">
          <label for="observaciones" class="form-label">Observaciones (opcional):</label>
          <textarea id="observaciones" v-model="observaciones" class="form-control" rows="2"></textarea>
        </div>
        <div class="d-flex justify-content-end">
          <button class="btn btn-secondary me-2" @click="cancelar">Cancelar</button>
          <button class="btn btn-primary" :disabled="loading || !selectedOficio" @click="aceptar">Aceptar</button>
        </div>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpOficioPage',
  data() {
    return {
      oficioOptions: [],
      selectedOficio: null,
      observaciones: '',
      loading: false,
      message: '',
      success: false,
      tramiteId: null,
      usuarioId: null
    }
  },
  created() {
    // Suponiendo que el tramiteId y usuarioId vienen por props o route params
    this.tramiteId = this.$route.query.tramite_id || null;
    this.usuarioId = this.$store.state.user.id || null;
    this.fetchOficioOptions();
  },
  methods: {
    fetchOficioOptions() {
      this.loading = true;
      fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getOficioOptions' })
      })
        .then(res => res.json())
        .then(json => {
          this.oficioOptions = json.data || [];
        })
        .finally(() => { this.loading = false; });
    },
    aceptar() {
      if (!this.selectedOficio) return;
      this.loading = true;
      this.message = '';
      fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'registerOficioDecision',
          params: {
            tramite_id: this.tramiteId,
            oficio_type: this.selectedOficio,
            usuario_id: this.usuarioId,
            observaciones: this.observaciones
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.success = json.success;
          this.message = json.message || (json.success ? 'Oficio registrado.' : 'Error al registrar.');
          if (json.success) {
            // Aquí podría redirigir o mostrar impresión
          }
        })
        .catch(() => {
          this.success = false;
          this.message = 'Error de comunicación con el servidor.';
        })
        .finally(() => { this.loading = false; });
    },
    cancelar() {
      this.$router.push('/tramites');
    }
  }
}
</script>

<style scoped>
.imp-oficio-page {
  max-width: 600px;
  margin: 40px auto;
}
.card {
  border-radius: 8px;
}
</style>
