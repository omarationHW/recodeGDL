<template>
  <div class="firma-electronica-page">
    <h1>Firma Electrónica de Requerimientos</h1>
    <div class="breadcrumb">Inicio / Firma Electrónica</div>
    <div class="form-section">
      <div class="form-row">
        <label>Aplicación:</label>
        <select v-model="form.modulo">
          <option :value="14">Estacionómetros</option>
          <option :value="28">Est. Exclusivos</option>
          <option :value="24">Est. Públicos</option>
        </select>
      </div>
      <div class="form-row">
        <label>Fecha de asignación al ejecutor:</label>
        <input type="date" v-model="form.fecha" />
      </div>
      <div class="form-row">
        <button @click="listarFolios">PASO 1: Seleccionar folios a firmar</button>
      </div>
      <div v-if="folios.length > 0">
        <h3>Folios disponibles para firma</h3>
        <table class="data-table">
          <thead>
            <tr>
              <th></th>
              <th>Folio</th>
              <th>Emisión</th>
              <th>Diligencia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="folio in folios" :key="folio.folio">
              <td><input type="checkbox" v-model="folio.selected" /></td>
              <td>{{ folio.folio }}</td>
              <td>{{ folio.fecemi }}</td>
              <td>{{ folio.descripcion }}</td>
            </tr>
          </tbody>
        </table>
        <div class="form-row">
          <button @click="enviarAFirma">PASO 2: Enviar datos a firma</button>
        </div>
      </div>
      <div v-if="procesoFirma">
        <div class="form-row">
          <label>Fecha que proceso firma (PASO 3):</label>
          <input type="date" v-model="form.fecha_firma" />
        </div>
        <div class="form-row">
          <button @click="generarFirmaElectronica">PASO 3: Generar firma electrónica</button>
        </div>
      </div>
      <div v-if="estadisticas">
        <h3>Estadísticas</h3>
        <ul>
          <li>Total de datos a firmar: {{ estadisticas.totalFolios }}</li>
          <li>Total de folios firmados: {{ estadisticas.firmados }}</li>
          <li>Total de folios firmados anteriormente: {{ estadisticas.firmadosAnterior }}</li>
          <li>Firmas generadas: {{ estadisticas.firmasGeneradas }}</li>
        </ul>
      </div>
      <div v-if="mensaje" class="mensaje">
        {{ mensaje }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FirmaElectronicaPage',
  data() {
    return {
      form: {
        modulo: 14,
        fecha: '',
        fecha_firma: ''
      },
      folios: [],
      procesoFirma: false,
      estadisticas: null,
      mensaje: ''
    };
  },
  methods: {
    async listarFolios() {
      this.mensaje = '';
      this.folios = [];
      this.estadisticas = null;
      this.procesoFirma = false;
      if (!this.form.fecha) {
        this.mensaje = 'Seleccione la fecha de asignación.';
        return;
      }
      const res = await this.apiRequest('listarFolios', {
        modulo: this.form.modulo,
        fecha: this.form.fecha
      });
      if (res.success) {
        this.folios = res.data.map(f => ({ ...f, selected: false }));
        this.mensaje = 'Seleccione los folios que desea firmar.';
      } else {
        this.mensaje = res.message;
      }
    },
    async enviarAFirma() {
      this.mensaje = '';
      const seleccionados = this.folios.filter(f => f.selected);
      if (seleccionados.length === 0) {
        this.mensaje = 'Debe seleccionar al menos un folio.';
        return;
      }
      // Simulación: Enviar datos a firma (en backend real, aquí se haría el proceso)
      this.procesoFirma = true;
      this.estadisticas = {
        totalFolios: seleccionados.length,
        firmados: 0,
        firmadosAnterior: 0,
        firmasGeneradas: 0
      };
      this.mensaje = 'Datos enviados a firma. Ahora puede generar la firma electrónica.';
    },
    async generarFirmaElectronica() {
      this.mensaje = '';
      if (!this.form.fecha_firma) {
        this.mensaje = 'Debe indicar la fecha de proceso de firma.';
        return;
      }
      // Simulación: Generar firma para cada folio seleccionado
      let firmados = 0;
      let firmadosAnterior = 0;
      let firmasGeneradas = 0;
      for (const folio of this.folios.filter(f => f.selected)) {
        // Aquí se llamaría al backend para generar la firma
        const res = await this.apiRequest('generarFirma', {
          modulo: this.form.modulo,
          tipoformato: folio.diligencia,
          id: folio.cvereq,
          fecha: this.form.fecha_firma,
          cadenaoriginal: (folio.cadena1 || '') + (folio.cadena2 || ''),
          ruta: ''
        });
        if (res.success && res.data && res.data[0] && res.data[0].codigo === 0) {
          firmados++;
          firmasGeneradas++;
        } else if (res.success && res.data && res.data[0] && res.data[0].codigo !== 0) {
          firmadosAnterior++;
        }
      }
      this.estadisticas = {
        totalFolios: this.folios.filter(f => f.selected).length,
        firmados,
        firmadosAnterior,
        firmasGeneradas
      };
      this.mensaje = 'Proceso de generación de firmas terminado.';
    },
    async apiRequest(action, params) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, ...params } })
        });
        const json = await res.json();
        return json.eResponse;
      } catch (e) {
        return { success: false, message: 'Error de red o servidor', data: null };
      }
    }
  }
};
</script>

<style scoped>
.firma-electronica-page {
  max-width: 900px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 1em;
}
.form-section {
  background: #f9f9f9;
  padding: 1.5em;
  border-radius: 6px;
}
.form-row {
  margin-bottom: 1em;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 220px;
  font-weight: bold;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1em;
}
.data-table th, .data-table td {
  border: 1px solid #ccc;
  padding: 0.5em;
  text-align: left;
}
.mensaje {
  color: #c00;
  font-weight: bold;
  margin-top: 1em;
}
</style>
