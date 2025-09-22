<template>
  <div class="carga-pagos-texto-page">
    <h1>Carga de Pagos Realizados en Mercado Libertad</h1>
    <div class="mb-3">
      <input type="file" @change="onFileChange" accept=".txt" />
      <button class="btn btn-primary" :disabled="!fileContent" @click="previewArchivo">Previsualizar Archivo</button>
    </div>
    <div v-if="pagos.length">
      <h2>Previsualización de Pagos</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Id Local</th>
            <th>Año</th>
            <th>Periodo</th>
            <th>Fecha Pago</th>
            <th>Oficina</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Importe</th>
            <th>Folio</th>
            <th>Fecha Actualización</th>
            <th>Usuario</th>
            <th>Rec</th>
            <th>Merc</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(pago, idx) in pagos" :key="idx">
            <td>{{ pago.num_pago }}</td>
            <td>{{ pago.id_local }}</td>
            <td>{{ pago.axo }}</td>
            <td>{{ pago.periodo }}</td>
            <td>{{ pago.fecha_pago }}</td>
            <td>{{ pago.oficina_pago }}</td>
            <td>{{ pago.caja_pago }}</td>
            <td>{{ pago.operacion_pago }}</td>
            <td>{{ pago.importe_pago }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.fecha_actualizacion }}</td>
            <td>{{ pago.id_usuario }}</td>
            <td>{{ pago.rec }}</td>
            <td>{{ pago.merc }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="importarPagos" :disabled="importando">Importar Pagos</button>
    </div>
    <div v-if="resumen">
      <h2>Resumen de Importación</h2>
      <ul>
        <li>Pagos Grabados: <b>{{ resumen.grabados }}</b></li>
        <li>Pagos ya Grabados: <b>{{ resumen.ya_grabados }}</b></li>
        <li>Adeudos Borrados: <b>{{ resumen.borrados }}</b></li>
        <li>Total Pagos: <b>{{ resumen.total }}</b></li>
        <li>Importe Total: <b>${{ resumen.importe_total.toFixed(2) }}</b></li>
      </ul>
    </div>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CargaPagosTextoPage',
  data() {
    return {
      fileContent: null,
      pagos: [],
      resumen: null,
      error: '',
      success: '',
      importando: false
    };
  },
  methods: {
    onFileChange(e) {
      this.error = '';
      this.success = '';
      this.resumen = null;
      this.pagos = [];
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.fileContent = btoa(evt.target.result);
      };
      reader.readAsBinaryString(file);
    },
    async previewArchivo() {
      this.error = '';
      this.success = '';
      this.resumen = null;
      this.pagos = [];
      if (!this.fileContent) {
        this.error = 'Seleccione un archivo primero.';
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'preview_pagos_texto',
            payload: {
              file_content: this.fileContent
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.pagos = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = 'Error al procesar el archivo.';
      }
    },
    async importarPagos() {
      if (!this.pagos.length) {
        this.error = 'No hay pagos para importar.';
        return;
      }
      this.importando = true;
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'importar_pagos_texto',
            payload: {
              pagos: this.pagos
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.resumen = data.data;
          this.success = 'Importación completada.';
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = 'Error al importar pagos.';
      } finally {
        this.importando = false;
      }
    }
  }
};
</script>

<style scoped>
.carga-pagos-texto-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.table {
  font-size: 0.95rem;
}
</style>
