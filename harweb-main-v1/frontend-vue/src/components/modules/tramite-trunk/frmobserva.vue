<template>
  <div class="obscomprob-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Observaciones de Comprobante</span>
    </div>
    <div class="panel">
      <h2>Modifica observaciones del último comprobante</h2>
      <div class="comprobante-info">
        <div><strong>Fecha:</strong> {{ comprobante.feccap }}</div>
        <div><strong>Capturista:</strong> {{ comprobante.capturista }}</div>
        <div><strong>Año:</strong> {{ comprobante.axocomp }}</div>
        <div><strong>Comprobante:</strong> {{ comprobante.nocomp }}</div>
      </div>
      <div class="form-group">
        <label for="observacion"><strong>Observaciones</strong></label>
        <textarea id="observacion" v-model="observacion" rows="8" @keypress="toUppercase" class="form-control"></textarea>
      </div>
      <div class="actions">
        <button @click="actualizarObservacion" :disabled="loading" class="btn btn-primary">
          {{ loading ? 'Actualizando...' : 'Actualizar' }}
        </button>
        <button @click="cancelar" class="btn btn-secondary">Cancelar</button>
      </div>
      <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
        {{ message }}
      </div>
    </div>
    <div class="historico-panel" v-if="historico">
      <h3>Histórico del Comprobante</h3>
      <pre>{{ historico }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ObsComprobPage',
  data() {
    return {
      comprobante: {
        feccap: '',
        capturista: '',
        axocomp: '',
        nocomp: '',
        observacion: ''
      },
      observacion: '',
      historico: null,
      loading: false,
      message: '',
      success: false
    };
  },
  created() {
    this.loadComprobante();
  },
  methods: {
    async loadComprobante() {
      // Suponiendo que el cvecuenta viene por query o prop
      const cvecuenta = this.$route.query.cvecuenta || 0;
      if (!cvecuenta) {
        this.message = 'Cuenta no especificada';
        this.success = false;
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_observa_comprobante',
            payload: { cvecuenta }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.comprobante = data.data;
          this.observacion = data.data.observacion || '';
        } else {
          this.message = data.message;
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de red';
        this.success = false;
      }
    },
    async actualizarObservacion() {
      this.loading = true;
      this.message = '';
      const cvecuenta = this.comprobante.cvecuenta;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'update_observa_comprobante',
            payload: {
              cvecuenta,
              observacion: this.observacion
            }
          })
        });
        const data = await res.json();
        this.loading = false;
        if (data.success) {
          this.message = data.data.message;
          this.success = true;
          this.loadComprobante();
        } else {
          this.message = data.message;
          this.success = false;
        }
      } catch (e) {
        this.loading = false;
        this.message = 'Error de red';
        this.success = false;
      }
    },
    cancelar() {
      this.$router.back();
    },
    toUppercase(e) {
      if (e.key.length === 1) {
        e.target.value += e.key.toUpperCase();
        e.preventDefault();
      }
    }
  }
};
</script>

<style scoped>
.obscomprob-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.panel {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #eee;
  padding: 2rem;
}
.comprobante-info {
  display: flex;
  gap: 2rem;
  margin-bottom: 1rem;
}
.form-group {
  margin-bottom: 1rem;
}
.actions {
  display: flex;
  gap: 1rem;
}
.alert {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
}
.alert-success {
  background: #e6ffe6;
  color: #1a7f1a;
}
.alert-danger {
  background: #ffe6e6;
  color: #a11a1a;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.historico-panel {
  margin-top: 2rem;
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
}
</style>
