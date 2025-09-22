<template>
  <div class="imp-recibo-page">
    <h1>Impresión de Recibos</h1>
    <div class="form-section">
      <label for="licencia">Licencia:</label>
      <input v-model="licencia" id="licencia" type="text" @change="reset" @keyup.enter="buscarLicencia" />
      <div class="radio-group">
        <label><input type="radio" value="constancia" v-model="tipo" /> Constancia</label>
        <label><input type="radio" value="certificacion" v-model="tipo" /> Certificación</label>
      </div>
      <button :disabled="!puedeImprimir" @click="imprimirRecibo">Imprimir</button>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="recibo" class="recibo-preview">
      <h2>Vista previa del recibo</h2>
      <p><strong>Licencia:</strong> {{ recibo.licencia }}</p>
      <p><strong>Nombre:</strong> {{ recibo.nombre }}</p>
      <p><strong>Domicilio:</strong> {{ recibo.domicilio }}</p>
      <p><strong>Concepto:</strong> {{ recibo.concepto }}</p>
      <p><strong>Cantidad:</strong> ${{ recibo.cantidad }}</p>
      <p><strong>Cantidad con letra:</strong> {{ recibo.cantidad_letra }}</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpReciboPage',
  data() {
    return {
      licencia: '',
      tipo: 'certificacion',
      recibo: null,
      puedeImprimir: false,
      error: ''
    };
  },
  methods: {
    reset() {
      this.recibo = null;
      this.puedeImprimir = false;
      this.error = '';
    },
    async buscarLicencia() {
      this.reset();
      if (!this.licencia) {
        this.error = 'Ingrese el número de licencia';
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getLicenciaRecibo',
            params: { licencia: this.licencia }
          })
        });
        const data = await res.json();
        if (data.success && data.data) {
          this.puedeImprimir = true;
          this.error = '';
        } else {
          this.error = data.message || 'No se encontró licencia con ese número';
        }
      } catch (e) {
        this.error = 'Error de conexión';
      }
    },
    async imprimirRecibo() {
      if (!this.licencia) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'printRecibo',
            params: { licencia: this.licencia, tipo: this.tipo }
          })
        });
        const data = await res.json();
        if (data.success && data.data) {
          this.recibo = data.data;
          this.error = '';
        } else {
          this.error = data.message || 'No se pudo generar el recibo';
        }
      } catch (e) {
        this.error = 'Error de conexión';
      }
    }
  }
};
</script>

<style scoped>
.imp-recibo-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  margin-bottom: 2rem;
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
}
.radio-group {
  margin: 1rem 0;
}
button {
  padding: 0.5rem 1.5rem;
  font-size: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.recibo-preview {
  background: #e6ffe6;
  padding: 1rem;
  border-radius: 6px;
}
</style>
