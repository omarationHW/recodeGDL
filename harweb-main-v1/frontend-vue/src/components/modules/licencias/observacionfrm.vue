<template>
  <div class="observacion-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Observaciones</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h4>Observaciones...</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group">
            <label for="observacion">Observación</label>
            <textarea
              id="observacion"
              v-model="observacion"
              class="form-control"
              rows="8"
              style="background-color: #f5f5dc;"
              @keypress="toUppercase"
              maxlength="2000"
              required
            ></textarea>
          </div>
          <div class="text-center mt-3">
            <button type="submit" class="btn btn-primary">
              <i class="fa fa-check"></i> Aceptar
            </button>
          </div>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
    <div class="card mt-4">
      <div class="card-header">
        <h5>Observaciones Guardadas</h5>
      </div>
      <div class="card-body">
        <ul class="list-group">
          <li v-for="obs in observaciones" :key="obs.id" class="list-group-item">
            {{ obs.observacion }}
            <span class="text-muted float-right">{{ obs.created_at | formatDate }}</span>
          </li>
          <li v-if="observaciones.length === 0" class="list-group-item text-muted">No hay observaciones registradas.</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ObservacionPage',
  data() {
    return {
      observacion: '',
      message: '',
      success: false,
      observaciones: []
    };
  },
  methods: {
    toUppercase(e) {
      // Convert character to uppercase as user types
      if (e.key.length === 1 && e.key.match(/[a-záéíóúñ]/i)) {
        const upper = e.key.toUpperCase();
        if (e.key !== upper) {
          e.preventDefault();
          const start = e.target.selectionStart;
          const end = e.target.selectionEnd;
          this.observacion =
            this.observacion.substring(0, start) +
            upper +
            this.observacion.substring(end);
          this.$nextTick(() => {
            e.target.setSelectionRange(start + 1, start + 1);
          });
        }
      }
    },
    async onSubmit() {
      this.message = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.save_observacion',
          payload: {
            observacion: this.observacion
          }
        });
        if (res.data.status === 'success') {
          this.message = res.data.message;
          this.success = true;
          this.observacion = '';
          this.loadObservaciones();
        } else {
          this.message = res.data.message || 'Error desconocido.';
          this.success = false;
        }
      } catch (error) {
        this.message = 'Error de red o del servidor.';
        this.success = false;
      }
    },
    async loadObservaciones() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.get_observaciones',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.observaciones = res.data.eResponse.data.result || [];
        } else {
          this.observaciones = [];
        }
      } catch (error) {
        this.observaciones = [];
      }
    }
  },
  filters: {
    formatDate(value) {
      if (!value) return '';
      return new Date(value).toLocaleString();
    }
  },
  mounted() {
    this.loadObservaciones();
  }
};
</script>

<style scoped>
.observacion-page {
  max-width: 650px;
  margin: 40px auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
textarea.form-control {
  font-size: 1.1em;
  font-family: 'Segoe UI', Arial, sans-serif;
  resize: vertical;
}
</style>
