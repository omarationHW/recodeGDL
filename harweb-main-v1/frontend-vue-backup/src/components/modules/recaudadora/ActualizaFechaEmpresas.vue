<template>
  <div class="actualiza-fecha-empresas">
    <h1>Actualiza Fecha de Práctica de Empresas</h1>
    <div class="form-section">
      <label for="ejecutor">Ejecutor:</label>
      <select v-model="ejecutor" id="ejecutor">
        <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">{{ e.empresa }}</option>
      </select>
      <label for="fechaCorte">Fecha de Corte:</label>
      <input type="date" v-model="fechaCorte" id="fechaCorte" />
      <input type="file" @change="onFileChange" accept=".txt" />
      <button @click="parseFile">Ver Archivo de texto</button>
    </div>
    <div v-if="folios.length">
      <h2>Folios a Procesar</h2>
      <table class="folios-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Clave Cuenta</th>
            <th>Folio</th>
            <th>Año Folio</th>
            <th>Propietario</th>
            <th>Importe Pagado</th>
            <th>Notificación</th>
            <th>Fecha Pago</th>
            <th>Estado</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(folio, idx) in folios" :key="idx">
            <td>{{ idx + 1 }}</td>
            <td>{{ folio.clave_cuenta }}</td>
            <td>{{ folio.folio }}</td>
            <td>{{ folio.anio_folio }}</td>
            <td>{{ folio.propietario }}</td>
            <td>{{ folio.importe_pagado }}</td>
            <td>{{ folio.notificacion }}</td>
            <td>{{ folio.fecha_pago }}</td>
            <td>{{ folio.estado }}</td>
            <td>
              <button @click="actualizaFolio(idx)">Actualizar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="summary">
        <p>Total de Folios: {{ folios.length }}</p>
        <p>Folios Correctos: {{ foliosCorrectos }}</p>
        <p>Folios Incorrectos: {{ foliosIncorrectos }}</p>
        <p>Folios Procesados: {{ foliosProcesados }}</p>
      </div>
      <button @click="actualizaTodos">Actualizar Todos</button>
    </div>
    <div v-if="errores.length">
      <h3>Errores</h3>
      <ul>
        <li v-for="(err, i) in errores" :key="i">
          Folio: {{ err.folio }} - Cuenta: {{ err.clave_cuenta }} - Año: {{ err.anio_folio }} - {{ err.error }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ActualizaFechaEmpresas',
  data() {
    return {
      ejecutor: '',
      ejecutores: [],
      fechaCorte: '',
      folios: [],
      errores: [],
      foliosCorrectos: 0,
      foliosIncorrectos: 0,
      foliosProcesados: 0,
      fileContent: ''
    };
  },
  mounted() {
    // Cargar ejecutores
    this.fetchEjecutores();
  },
  methods: {
    fetchEjecutores() {
      // Simulación: en producción, llamar a /api/execute con action: 'get_ejecutores'
      this.ejecutores = [
        { cveejecutor: 1, empresa: 'EMPRESA 1' },
        { cveejecutor: 2, empresa: 'EMPRESA 2' }
      ];
    },
    onFileChange(e) {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.fileContent = evt.target.result;
      };
      reader.readAsText(file);
    },
    async parseFile() {
      if (!this.fileContent) {
        alert('Seleccione un archivo primero');
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.parse_file',
          payload: { file_content: this.fileContent }
        });
        if (res.data.status === 'success') {
          this.folios = res.data.data;
          this.foliosProcesados = 0;
          this.foliosCorrectos = 0;
          this.foliosIncorrectos = 0;
          this.errores = [];
        } else {
          alert(res.data.message);
        }
      } catch (error) {
        alert('Error de conexión: ' + error.message);
      }
    },
    async actualizaFolio(idx) {
      const folio = this.folios[idx];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.actualiza_fechas',
          payload: {
            folios: [
              {
                clave_cuenta: folio.clave_cuenta,
                folio: folio.folio,
                anio_folio: folio.anio_folio,
                fecha_practica: this.fechaCorte
              }
            ]
          }
        });
        if (res.data.status === 'success') {
          this.foliosProcesados++;
          this.foliosCorrectos++;
          folio.estado = 'ACTUALIZADO';
        } else {
          this.foliosProcesados++;
          this.foliosIncorrectos++;
          this.errores.push({
            folio: folio.folio,
            clave_cuenta: folio.clave_cuenta,
            anio_folio: folio.anio_folio,
            error: res.data.message
          });
          folio.estado = 'PENDIENTE';
        }
      } catch (error) {
        this.foliosProcesados++;
        this.foliosIncorrectos++;
        this.errores.push({
          folio: folio.folio,
          clave_cuenta: folio.clave_cuenta,
          anio_folio: folio.anio_folio,
          error: 'Error de conexión: ' + error.message
        });
        folio.estado = 'PENDIENTE';
      }
    },
    async actualizaTodos() {
      if (!this.fechaCorte) {
        alert('Seleccione la fecha de corte');
        return;
      }
      const foliosToUpdate = this.folios.map(f => ({
        clave_cuenta: f.clave_cuenta,
        folio: f.folio,
        anio_folio: f.anio_folio,
        fecha_practica: this.fechaCorte
      }));
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.actualiza_fechas',
          payload: { folios: foliosToUpdate }
        });
        if (res.data.status === 'success') {
          this.foliosProcesados = res.data.data.aplicados + res.data.data.pendientes;
          this.foliosCorrectos = res.data.data.aplicados;
          this.foliosIncorrectos = res.data.data.pendientes;
          this.errores = res.data.data.errores;
          // Actualiza estados en la tabla
          this.folios.forEach(f => {
            const err = this.errores.find(e => e.folio == f.folio && e.clave_cuenta == f.clave_cuenta);
            f.estado = err ? 'PENDIENTE' : 'ACTUALIZADO';
          });
        } else {
          alert(res.data.message);
        }
      } catch (error) {
        alert('Error de conexión: ' + error.message);
      }
    }
  }
};
</script>

<style scoped>
.actualiza-fecha-empresas {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-section {
  margin-bottom: 2rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}
.folios-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.folios-table th, .folios-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.summary {
  margin-top: 1rem;
  font-weight: bold;
}
</style>
