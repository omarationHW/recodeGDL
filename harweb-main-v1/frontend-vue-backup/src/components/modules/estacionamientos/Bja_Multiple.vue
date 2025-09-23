<template>
  <div class="bja-multiple-page">
    <h1>Baja Múltiple de Folios</h1>
    <div class="form-section">
      <label for="archivo">Archivo a procesar:</label>
      <input v-model="archivo" id="archivo" maxlength="20" class="input-archivo" />
    </div>
    <div class="spreadsheet-section">
      <table class="spreadsheet-table">
        <thead>
          <tr>
            <th>PLACA</th>
            <th>FOLIO</th>
            <th>FECHA</th>
            <th>ANOMALIA</th>
            <th>TARIFA</th>
            <th>REFERENCIA</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in registros" :key="idx">
            <td><input v-model="row.placa" /></td>
            <td><input v-model.number="row.folio_archivo" type="number" /></td>
            <td><input v-model="row.fecha_archivo" type="date" /></td>
            <td><input v-model="row.anomalia" /></td>
            <td><input v-model="row.tarifa" disabled /></td>
            <td><input v-model.number="row.referencia" type="number" /></td>
            <td><button @click="removeRow(idx)">Eliminar</button></td>
          </tr>
        </tbody>
      </table>
      <button @click="addRow">Agregar fila</button>
    </div>
    <div class="actions-section">
      <button @click="grabar" :disabled="!canGrabar">Grabar</button>
      <button @click="llenado" v-if="showLlenado">Llenado y Aplicado</button>
      <button @click="vista" v-if="showVista">Vista</button>
      <button @click="salir">Salir</button>
    </div>
    <div class="info-section">
      <div v-if="grabacionMsg" class="info-msg">{{ grabacionMsg }}</div>
      <div v-if="aplicacionMsg" class="info-msg">{{ aplicacionMsg }}</div>
    </div>
    <div v-if="showIncidencias" class="incidencias-section">
      <h2>Registros con error de Validación</h2>
      <table class="incidencias-table">
        <thead>
          <tr>
            <th>PLACA</th>
            <th>FOLIO</th>
            <th>FECHA</th>
            <th>ANOMALIA</th>
            <th>REFERENCIA</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(inc, idx) in incidencias" :key="idx">
            <td>{{ inc.placa }}</td>
            <td>{{ inc.folio_archivo }}</td>
            <td>{{ inc.fecha_archivo }}</td>
            <td>{{ inc.anomalia }}</td>
            <td>{{ inc.referencia }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="showIncidencias = false">Cerrar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BjaMultiplePage',
  data() {
    return {
      archivo: '',
      registros: [
        { placa: '', folio_archivo: '', fecha_archivo: '', anomalia: '', tarifa: '', referencia: '' }
      ],
      grabacionMsg: '',
      aplicacionMsg: '',
      incidencias: [],
      showLlenado: false,
      showVista: false,
      showIncidencias: false
    };
  },
  computed: {
    canGrabar() {
      return this.archivo.trim() !== '' && this.registros.length > 0 && this.registros.some(r => r.placa && r.folio_archivo && r.fecha_archivo && r.anomalia && r.referencia);
    }
  },
  methods: {
    addRow() {
      this.registros.push({ placa: '', folio_archivo: '', fecha_archivo: '', anomalia: '', tarifa: '', referencia: '' });
    },
    removeRow(idx) {
      this.registros.splice(idx, 1);
    },
    async grabar() {
      if (!this.canGrabar) {
        alert('Falta el dato del archivo o datos incompletos');
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.insert_baja_multiple',
          payload: {
            archivo: this.archivo,
            registros: this.registros.filter(r => r.placa && r.folio_archivo && r.fecha_archivo && r.anomalia && r.referencia)
          }
        });
        if (res.data.status === 'success') {
          this.grabacionMsg = `Registros Procesados ${this.registros.length} del archivo "${this.archivo}"`;
          this.showLlenado = true;
        } else {
          alert(res.data.message);
        }
      } catch (error) {
        alert('Error en la carga de folios: ' + error);
      }
    },
    async llenado() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.aplicar_baja_multiple'
        });
        if (res.data.status === 'success') {
          this.aplicacionMsg = 'Terminó el llenado de datos a los folios grabados y su Aplicación';
          this.showLlenado = false;
          this.showVista = true;
        } else {
          alert(res.data.message);
        }
      } catch (error) {
        alert('Error en el llenado: ' + error);
      }
    },
    async vista() {
      if (!this.archivo) {
        alert('No tiene dato del archivo a búsqueda para impresión de Incidencias');
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.get_incidencias_baja_multiple',
          payload: { archivo: this.archivo }
        });
        if (res.data.status === 'success' && res.data.data && res.data.data.length > 0) {
          this.incidencias = res.data.data;
          this.showIncidencias = true;
          this.showVista = false;
        } else {
          alert('No hay impresión pues no generó errores de validación');
        }
      } catch (error) {
        alert('Error al obtener incidencias: ' + error);
      }
    },
    salir() {
      // Redirigir a inicio o cerrar la página
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.bja-multiple-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  margin-bottom: 1rem;
}
.input-archivo {
  font-weight: bold;
  font-size: 1.1rem;
  width: 200px;
}
.spreadsheet-section {
  margin-bottom: 1rem;
}
.spreadsheet-table, .incidencias-table {
  width: 100%;
  border-collapse: collapse;
}
.spreadsheet-table th, .spreadsheet-table td, .incidencias-table th, .incidencias-table td {
  border: 1px solid #ccc;
  padding: 0.3rem;
  text-align: center;
}
.actions-section {
  margin-bottom: 1rem;
}
.actions-section button {
  margin-right: 1rem;
}
.info-section {
  margin-bottom: 1rem;
}
.info-msg {
  font-weight: bold;
  color: #2a7;
}
.incidencias-section {
  background: #f9f9f9;
  border: 1px solid #aaa;
  padding: 1rem;
  margin-top: 2rem;
}
</style>
