<template>
  <div class="rechazo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/tramites">Trámites</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Rechazo de Transmisión</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Rechazo de Transmisión Patrimonial</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label for="folio" class="form-label">Folio de Transmisión</label>
            <input type="number" v-model="form.folio" id="folio" class="form-control" required />
          </div>
          <div class="mb-3">
            <label for="motivo" class="form-label">Motivo del Rechazo</label>
            <textarea v-model="form.motivo" id="motivo" class="form-control" rows="4" required @input="toUppercase"></textarea>
          </div>
          <div class="mb-3">
            <label for="usuario" class="form-label">Usuario</label>
            <input type="text" v-model="form.usuario" id="usuario" class="form-control" required />
          </div>
          <button type="submit" class="btn btn-danger" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm"></span>
            Rechazar Transmisión
          </button>
        </form>
        <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}" class="mt-3">
          {{ message }}
        </div>
      </div>
    </div>
    <div class="card mt-4">
      <div class="card-header">
        <h5>Consulta de Motivo de Rechazo</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="onConsultarMotivo">
          <div class="mb-3">
            <label for="folioConsulta" class="form-label">Folio</label>
            <input type="number" v-model="folioConsulta" id="folioConsulta" class="form-control" />
          </div>
          <button type="submit" class="btn btn-primary">Consultar Motivo</button>
        </form>
        <div v-if="motivoRechazo" class="mt-3">
          <strong>Motivo:</strong> {{ motivoRechazo.motivo }}<br />
          <strong>Fecha de Rechazo:</strong> {{ motivoRechazo.fecha_rechazo }}<br />
          <strong>Usuario:</strong> {{ motivoRechazo.usuario }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RechazoTransmisionPage',
  data() {
    return {
      form: {
        folio: '',
        motivo: '',
        usuario: ''
      },
      loading: false,
      message: '',
      success: false,
      folioConsulta: '',
      motivoRechazo: null
    };
  },
  methods: {
    toUppercase(e) {
      this.form.motivo = this.form.motivo.toUpperCase();
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      this.success = false;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'rechazar_transmision',
              folio: this.form.folio,
              motivo: this.form.motivo,
              usuario: this.form.usuario
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.message = data.eResponse.message;
          this.success = true;
          this.form.motivo = '';
        } else {
          this.message = data.eResponse.message || 'Error al rechazar la transmisión.';
          this.success = false;
        }
      } catch (err) {
        this.message = 'Error de red o del servidor.';
        this.success = false;
      }
      this.loading = false;
    },
    async onConsultarMotivo() {
      if (!this.folioConsulta) {
        this.motivoRechazo = null;
        return;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'get_motivo_rechazo',
              folio: this.folioConsulta
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.motivoRechazo = data.eResponse;
        } else {
          this.motivoRechazo = null;
        }
      } catch (err) {
        this.motivoRechazo = null;
      }
    }
  }
};
</script>

<style scoped>
.rechazo-page {
  max-width: 600px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
</style>
