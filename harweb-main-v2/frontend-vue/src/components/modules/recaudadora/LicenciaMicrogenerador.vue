<template>
  <div class="licencia-microgenerador-page">
    <div class="header">
      <h1>Licencias con Microgenerador</h1>
    </div>
    <div class="form-section">
      <label for="tipo">Tipo:</label>
      <select v-model="tipo" id="tipo">
        <option value="L">Licencia</option>
        <option value="T">Trámite</option>
      </select>
      <label v-if="tipo==='L'" for="licencia">Licencia:</label>
      <input v-if="tipo==='L'" v-model="licencia" id="licencia" type="number" />
      <label v-if="tipo==='T'" for="tramite">Trámite:</label>
      <input v-if="tipo==='T'" v-model="tramite" id="tramite" type="number" />
      <button @click="consulta">Consultar</button>
    </div>
    <div v-if="info" class="info-section">
      <div v-if="tipo==='L'">
        <p><b>Licencia:</b> {{ info.licencia }}</p>
        <p><b>Nombre:</b> {{ info.nombre }}</p>
        <p><b>Domicilio:</b> {{ info.ubicacion }}</p>
        <p><b>Actividad:</b> {{ info.actividad }}</p>
      </div>
      <div v-else>
        <p><b>Trámite:</b> {{ info.id_tramite }}</p>
        <p><b>Nombre:</b> {{ info.nombre }}</p>
        <p><b>Domicilio:</b> {{ info.ubicacion }}</p>
        <p><b>Actividad:</b> {{ info.actividad }}</p>
      </div>
      <div class="mensaje" v-if="mensaje">
        <p :class="{'success': estatus===1, 'error': estatus!==1}">{{ mensaje }}</p>
      </div>
      <div class="actions">
        <button v-if="estatus===2" @click="alta">Registrar como microgenerador</button>
        <button v-if="estatus===1" @click="cancelar">Cancelar microgenerador</button>
      </div>
    </div>
    <div v-if="mensaje && !info" class="mensaje">
      <p class="error">{{ mensaje }}</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LicenciaMicrogenerador',
  data() {
    return {
      tipo: 'L',
      licencia: '',
      tramite: '',
      info: null,
      mensaje: '',
      estatus: 0,
      id: null
    }
  },
  methods: {
    async consulta() {
      this.info = null;
      this.mensaje = '';
      this.estatus = 0;
      let params = { tipo: this.tipo };
      if (this.tipo === 'L') params.licencia = this.licencia;
      else params.tramite = this.tramite;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'consulta', params })
      });
      const data = await res.json();
      if (data.licencia || data.tramite) {
        this.info = data.licencia || data.tramite;
        this.mensaje = data.mensaje;
        this.estatus = data.estatus;
        this.id = this.tipo === 'L' ? this.info.id_licencia : this.info.id_tramite;
      } else {
        this.info = null;
        this.mensaje = data.mensaje;
        this.estatus = data.estatus;
      }
    },
    async alta() {
      const params = { tipo: this.tipo, id: this.id };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'alta', params })
      });
      const data = await res.json();
      this.mensaje = data.mensaje;
      this.estatus = data.estatus;
      await this.consulta();
    },
    async cancelar() {
      const params = { tipo: this.tipo, id: this.id };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'cancelar', params })
      });
      const data = await res.json();
      this.mensaje = data.mensaje;
      this.estatus = data.estatus;
      await this.consulta();
    }
  }
}
</script>

<style scoped>
.licencia-microgenerador-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px #0001;
}
.header {
  margin-bottom: 24px;
}
.form-section {
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.info-section {
  background: #f7f7fa;
  border-radius: 6px;
  padding: 18px;
  margin-bottom: 16px;
}
.mensaje {
  margin-top: 12px;
}
.mensaje .success {
  color: #2e7d32;
  font-weight: bold;
}
.mensaje .error {
  color: #c62828;
  font-weight: bold;
}
.actions {
  margin-top: 18px;
  display: flex;
  gap: 10px;
}
button {
  padding: 8px 18px;
  border-radius: 4px;
  border: none;
  background: #1976d2;
  color: #fff;
  font-weight: bold;
  cursor: pointer;
}
button[disabled] {
  background: #ccc;
  cursor: not-allowed;
}
</style>
