<template>
  <div class="modificar-apremio-page">
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Apremios</span> &gt; <span>Modificar Folio</span>
    </nav>
    <h1>Modificar Folio de Apremios</h1>
    <form @submit.prevent="verificarFolio">
      <div class="form-row">
        <label>Apliación:</label>
        <select v-model="form.modulo">
          <option :value="11">11 Mercados</option>
          <option :value="16">16 Aseo</option>
        </select>
        <label>Rec:</label>
        <input type="number" v-model.number="form.recaudadora" min="1" max="99" />
        <label>Folio:</label>
        <input type="number" v-model.number="form.folio" min="1" />
        <button type="submit">Verificar</button>
      </div>
    </form>
    <div v-if="folioData" class="folio-details">
      <h2>Datos del Folio</h2>
      <form @submit.prevent="modificarFolio">
        <div class="form-row">
          <label>Control:</label>
          <input v-model="folioData.id_control" disabled />
          <label>Rec Folio:</label>
          <input v-model="folioData.zona" disabled />
          <label>Llave Control:</label>
          <input v-model="folioData.control_otr" disabled />
          <label>Diligencia:</label>
          <input v-model="folioData.diligencia" disabled />
        </div>
        <div class="form-row">
          <label>Fecha Emisión:</label>
          <input v-model="folioData.fecha_emision" disabled />
          <label>Fecha Modif:</label>
          <input v-model="folioData.fecha_actualiz" disabled />
          <label>Usuario:</label>
          <input v-model="folioData.usuario" disabled />
        </div>
        <div class="form-row">
          <label>Imp. Adeudo:</label>
          <input v-model.number="folioData.importe_global" type="number" step="0.01" disabled />
          <label>Imp. Recargo:</label>
          <input v-model.number="folioData.importe_recargo" type="number" step="0.01" disabled />
          <label>Imp. Multa:</label>
          <input v-model.number="folioData.importe_multa" type="number" step="0.01" :disabled="folioData.importe_multa > 0" />
          <label>Imp. Gastos:</label>
          <input v-model.number="folioData.importe_gastos" type="number" step="0.01" :disabled="folioData.importe_gastos > 0" />
        </div>
        <div class="form-row">
          <label>Zona Apremio:</label>
          <input v-model.number="folioData.zona_apremio" type="number" min="1" />
          <label>Observaciones:</label>
          <input v-model="folioData.observaciones" maxlength="255" />
        </div>
        <!-- Más campos según lógica -->
        <div class="form-row">
          <button type="submit">Modificar</button>
          <button type="button" @click="resetForm">Limpiar</button>
        </div>
      </form>
      <div v-if="historial.length">
        <h3>Historial de Cambios</h3>
        <table class="historial-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Usuario</th>
              <th>Movimiento</th>
              <th>Observaciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="h in historial" :key="h.fecha_actualiz + '-' + h.usuario">
              <td>{{ h.fecha_actualiz }}</td>
              <td>{{ h.usuario }}</td>
              <td>{{ h.clave_mov }}</td>
              <td>{{ h.observaciones }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="errors.length" class="error-list">
      <ul>
        <li v-for="err in errors" :key="err">{{ err }}</li>
      </ul>
    </div>
    <div v-if="successMessage" class="success-message">
      {{ successMessage }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModificarApremio',
  data() {
    return {
      form: {
        modulo: 11,
        recaudadora: 1,
        folio: ''
      },
      folioData: null,
      historial: [],
      errors: [],
      successMessage: ''
    }
  },
  methods: {
    async verificarFolio() {
      this.errors = [];
      this.successMessage = '';
      this.folioData = null;
      this.historial = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getFolio',
          params: {
            modulo: this.form.modulo,
            folio: this.form.folio,
            recaudadora: this.form.recaudadora
          }
        });
        const data = res.data.eResponse;
        if (data.status === 'ok' && data.data.length) {
          this.folioData = data.data[0];
          await this.cargarHistorial(this.folioData.id_control);
        } else {
          this.errors = data.errors.length ? data.errors : ['No existe Registro con esos datos'];
        }
      } catch (e) {
        this.errors = [e.message];
      }
    },
    async cargarHistorial(id_control) {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'historialFolio',
          params: { id_control }
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.historial = data.data;
        }
      } catch (e) {
        this.errors.push('Error al cargar historial: ' + e.message);
      }
    },
    async modificarFolio() {
      this.errors = [];
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'modificarFolio',
          params: {
            ...this.folioData,
            usuario: this.$store.state.usuario.id // Asumimos login
          }
        });
        const data = res.data.eResponse;
        if (data.status === 'ok') {
          this.successMessage = 'El Registro se ha modificado';
          await this.cargarHistorial(this.folioData.id_control);
        } else {
          this.errors = data.errors.length ? data.errors : ['Error al modificar'];
        }
      } catch (e) {
        this.errors = [e.message];
      }
    },
    resetForm() {
      this.folioData = null;
      this.historial = [];
      this.errors = [];
      this.successMessage = '';
    }
  }
}
</script>

<style scoped>
.modificar-apremio-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2em;
  border-radius: 8px;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1em;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
  margin-bottom: 1em;
}
.form-row label {
  min-width: 120px;
  font-weight: bold;
}
.folio-details {
  margin-top: 2em;
  background: #f9f9f9;
  padding: 1em;
  border-radius: 6px;
}
.historial-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1em;
}
.historial-table th, .historial-table td {
  border: 1px solid #ccc;
  padding: 0.5em;
}
.error-list {
  color: #b00;
  margin-top: 1em;
}
.success-message {
  color: #080;
  margin-top: 1em;
  font-weight: bold;
}
</style>
