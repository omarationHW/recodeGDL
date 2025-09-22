<template>
  <div class="container">
    <h1>Autorización Microgenerador Ecología</h1>
    <div class="form-section">
      <label for="tipo">Tipo:</label>
      <select v-model="tipo" id="tipo">
        <option value="">Seleccione</option>
        <option value="T">Trámite</option>
        <option value="L">Licencia</option>
      </select>
      <label v-if="tipo === 'T'" for="tramite_id">ID Trámite:</label>
      <input v-if="tipo === 'T'" v-model="id" id="tramite_id" type="number" placeholder="ID Trámite" />
      <label v-if="tipo === 'L'" for="licencia">Licencia:</label>
      <input v-if="tipo === 'L'" v-model="id" id="licencia" type="number" placeholder="Número de Licencia" />
      <button @click="consulta">Consultar</button>
    </div>
    <div v-if="mensaje" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ mensaje }}
    </div>
    <div v-if="licenciaData">
      <h2>Datos {{ tipo === 'T' ? 'Trámite' : 'Licencia' }}</h2>
      <table class="table table-bordered">
        <tr><th>ID Trámite</th><td>{{ licenciaData.id_tramite || '-' }}</td></tr>
        <tr><th>Folio</th><td>{{ licenciaData.folio || '-' }}</td></tr>
        <tr><th>ID Licencia</th><td>{{ licenciaData.id_licencia }}</td></tr>
        <tr><th>Licencia Ref</th><td>{{ licenciaData.licencia_ref || licenciaData.licencia }}</td></tr>
        <tr><th>Nombre</th><td>{{ licenciaData.nombre }}</td></tr>
        <tr><th>Ubicación</th><td>{{ licenciaData.ubicacion }}</td></tr>
        <tr><th>Actividad</th><td>{{ licenciaData.actividad }}</td></tr>
      </table>
      <div class="actions">
        <button v-if="!esMicrogenerador" @click="alta" class="btn btn-success">Autorizar como Microgenerador</button>
        <button v-if="esMicrogenerador" @click="cancela" class="btn btn-danger">Cancelar Microgenerador</button>
      </div>
    </div>
    <div v-if="spResult">
      <h3>Resultado</h3>
      <div :class="{'alert-success': spResult.estatus === 1, 'alert-danger': spResult.estatus !== 1}" class="alert">
        {{ spResult.mensaje }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LicenciaMicrogeneradorEcologia',
  data() {
    return {
      tipo: '',
      id: '',
      licenciaData: null,
      spResult: null,
      mensaje: '',
      success: true,
      esMicrogenerador: false
    };
  },
  methods: {
    async consulta() {
      this.mensaje = '';
      this.licenciaData = null;
      this.spResult = null;
      this.esMicrogenerador = false;
      if (!this.tipo || !this.id) {
        this.mensaje = 'Debe seleccionar tipo y capturar el número.';
        this.success = false;
        return;
      }
      let action = this.tipo === 'T' ? 'tramite' : 'licencia';
      let payload = {
        action,
        data: this.tipo === 'T' ? { tramite_id: this.id } : { licencia: this.id }
      };
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        let json = await res.json();
        if (json.success && json.data) {
          this.licenciaData = json.data;
          // Ahora consultar si ya es microgenerador
          let consultaMG = await fetch('/api/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              action: 'consulta',
              data: { tipo: this.tipo, id: this.licenciaData.id_licencia }
            })
          });
          let mgJson = await consultaMG.json();
          if (mgJson.success && mgJson.data && mgJson.data.length > 0) {
            let estatus = mgJson.data[0].estatus;
            this.esMicrogenerador = (estatus === 1);
            this.spResult = mgJson.data[0];
            this.mensaje = mgJson.data[0].mensaje;
            this.success = (estatus === 1);
          } else {
            this.esMicrogenerador = false;
            this.spResult = null;
            this.mensaje = '';
          }
        } else {
          this.mensaje = json.message || 'No se encontró información.';
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    },
    async alta() {
      if (!this.licenciaData) return;
      let payload = {
        action: 'alta',
        data: { tipo: this.tipo, id: this.licenciaData.id_licencia }
      };
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        let json = await res.json();
        if (json.success && json.data && json.data.length > 0) {
          this.spResult = json.data[0];
          this.mensaje = json.data[0].mensaje;
          this.success = (json.data[0].estatus === 1);
          this.esMicrogenerador = (json.data[0].estatus === 1);
        } else {
          this.mensaje = json.message || 'No se pudo autorizar.';
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    },
    async cancela() {
      if (!this.licenciaData) return;
      let payload = {
        action: 'cancela',
        data: { tipo: this.tipo, id: this.licenciaData.id_licencia }
      };
      try {
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        let json = await res.json();
        if (json.success && json.data && json.data.length > 0) {
          this.spResult = json.data[0];
          this.mensaje = json.data[0].mensaje;
          this.success = (json.data[0].estatus === 1);
          this.esMicrogenerador = false;
        } else {
          this.mensaje = json.message || 'No se pudo cancelar.';
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor.';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #f9f9f9;
  border-radius: 8px;
}
.form-section {
  margin-bottom: 1.5rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}
.alert {
  margin: 1rem 0;
  padding: 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffe6;
  color: #1a7f1a;
}
.alert-danger {
  background: #ffe6e6;
  color: #a11a1a;
}
.actions {
  margin-top: 1rem;
}
.btn {
  padding: 0.5rem 1.5rem;
  font-size: 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.btn-success {
  background: #28a745;
  color: #fff;
  margin-right: 1rem;
}
.btn-danger {
  background: #dc3545;
  color: #fff;
}
.table {
  width: 100%;
  margin-top: 1rem;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
</style>
