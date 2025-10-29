<template>
  <div class="abcf-page">
    <h1>Modificación y Baja de Datos de Cementerios por Folio</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label for="folio">Folio</label>
        <input v-model="folio" id="folio" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="folioData">
      <form @submit.prevent="onGuardar">
        <fieldset>
          <legend>Datos del Folio</legend>
          <div class="form-row">
            <label>Cementerio</label>
            <select v-model="folioData.cementerio">
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">{{ cem.nombre }}</option>
            </select>
          </div>
          <div class="form-row">
            <label>Clase</label>
            <input v-model="folioData.clase" type="number" min="1" max="3" />
            <label>Clase Alfa</label>
            <input v-model="folioData.clase_alfa" maxlength="10" />
          </div>
          <div class="form-row">
            <label>Sección</label>
            <input v-model="folioData.seccion" type="number" min="1" />
            <label>Sección Alfa</label>
            <input v-model="folioData.seccion_alfa" maxlength="10" />
          </div>
          <div class="form-row">
            <label>Línea</label>
            <input v-model="folioData.linea" type="number" min="1" />
            <label>Línea Alfa</label>
            <input v-model="folioData.linea_alfa" maxlength="20" />
          </div>
          <div class="form-row">
            <label>Fosa</label>
            <input v-model="folioData.fosa" type="number" min="1" />
            <label>Fosa Alfa</label>
            <input v-model="folioData.fosa_alfa" maxlength="20" />
          </div>
          <div class="form-row">
            <label>Último Año de Pago (UAP)</label>
            <input v-model="folioData.axo_pagado" type="number" min="1994" />
            <label>Metros</label>
            <input v-model="folioData.metros" type="number" step="0.001" min="0.5" />
          </div>
          <div class="form-row">
            <label>Nombre</label>
            <input v-model="folioData.nombre" maxlength="60" />
          </div>
          <div class="form-row">
            <label>Domicilio</label>
            <input v-model="folioData.domicilio" maxlength="60" />
            <label>Ext</label>
            <input v-model="folioData.exterior" maxlength="6" />
            <label>Int</label>
            <input v-model="folioData.interior" maxlength="6" />
          </div>
          <div class="form-row">
            <label>Colonia</label>
            <input v-model="folioData.colonia" maxlength="30" />
          </div>
          <div class="form-row">
            <label>Observaciones</label>
            <input v-model="folioData.observaciones" maxlength="60" />
          </div>
          <div class="form-row">
            <label>Tipo</label>
            <select v-model="folioData.tipo">
              <option value="F">Fosa</option>
              <option value="U">Urna</option>
              <option value="G">Gaveta</option>
            </select>
          </div>
        </fieldset>
        <fieldset>
          <legend>Datos Adicionales</legend>
          <div class="form-row">
            <label>Teléfono</label>
            <input v-model="adicional.telefono" maxlength="10" />
            <label>RFC</label>
            <input v-model="adicional.rfc" maxlength="13" />
          </div>
          <div class="form-row">
            <label>CURP</label>
            <input v-model="adicional.curp" maxlength="18" />
            <label>Clave IFE</label>
            <input v-model="adicional.clave_ife" maxlength="18" />
          </div>
        </fieldset>
        <div class="form-actions">
          <button type="submit">Guardar Cambios</button>
          <button type="button" @click="onBaja" class="danger">Dar de Baja</button>
        </div>
      </form>
      <div v-if="adeudos && adeudos.length">
        <h3>Adeudos Vigentes</h3>
        <table class="table">
          <thead>
            <tr>
              <th>Año</th>
              <th>Importe</th>
              <th>Recargos</th>
              <th>Descto Importe</th>
              <th>Descto Recargos</th>
              <th>Actualización</th>
              <th>Usuario</th>
              <th>Fecha Mov</th>
              <th>ID Pago</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ad in adeudos" :key="ad.id_adeudo">
              <td>{{ ad.axo_adeudo }}</td>
              <td>{{ ad.importe }}</td>
              <td>{{ ad.importe_recargos }}</td>
              <td>{{ ad.descto_impote }}</td>
              <td>{{ ad.descto_recargos }}</td>
              <td>{{ ad.actualizacion }}</td>
              <td>{{ ad.usuario }}</td>
              <td>{{ ad.fecha_mov }}</td>
              <td>{{ ad.id_pago }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ABCFolioPage',
  data() {
    return {
      folio: '',
      folioData: null,
      adicional: {
        telefono: '',
        rfc: '',
        curp: '',
        clave_ife: ''
      },
      adeudos: [],
      cementerios: [],
      error: ''
    };
  },
  created() {
    this.fetchCementerios();
  },
  methods: {
    async fetchCementerios() {
      // Simulación: en producción, usar API
      this.cementerios = [
        { cementerio: 'A', nombre: 'Cementerio A' },
        { cementerio: 'B', nombre: 'Cementerio B' },
        { cementerio: 'C', nombre: 'Cementerio C' }
      ];
    },
    async onBuscar() {
      this.error = '';
      this.folioData = null;
      this.adicional = { telefono: '', rfc: '', curp: '', clave_ife: '' };
      this.adeudos = [];
      try {
        const res = await axios.post('/api/execute', {
          eRequest: { action: 'get', folio: this.folio }
        });
        if (res.data.eResponse.success) {
          this.folioData = res.data.eResponse.data.folio;
          this.adicional = res.data.eResponse.data.adicional || { telefono: '', rfc: '', curp: '', clave_ife: '' };
          this.adeudos = res.data.eResponse.data.adeudos || [];
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      }
    },
    async onGuardar() {
      this.error = '';
      try {
        // Actualizar folio
        const res = await axios.post('/api/execute', {
          eRequest: { action: 'update', folio: this.folio, ...this.folioData }
        });
        if (!res.data.eResponse.success) {
          this.error = res.data.eResponse.message;
          return;
        }
        // Actualizar adicional
        await axios.post('/api/execute', {
          eRequest: { action: 'updateAdicional', folio: this.folio, ...this.adicional }
        });
        alert('Datos guardados correctamente');
        this.onBuscar();
      } catch (e) {
        this.error = 'Error al guardar cambios';
      }
    },
    async onBaja() {
      if (!confirm('¿Está seguro de dar de baja este folio?')) return;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: { action: 'delete', folio: this.folio }
        });
        if (res.data.eResponse.success) {
          alert('Folio dado de baja');
          this.folioData = null;
          this.adicional = { telefono: '', rfc: '', curp: '', clave_ife: '' };
          this.adeudos = [];
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al dar de baja';
      }
    }
  }
};
</script>

<style scoped>
.abcf-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 120px;
  margin-right: 0.5rem;
}
.form-row input, .form-row select {
  margin-right: 1rem;
  flex: 1 1 0;
}
.form-actions {
  margin-top: 1.5rem;
}
.form-actions button {
  margin-right: 1rem;
}
.danger {
  background: #c00;
  color: #fff;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: #c00;
  margin: 1rem 0;
}
</style>
