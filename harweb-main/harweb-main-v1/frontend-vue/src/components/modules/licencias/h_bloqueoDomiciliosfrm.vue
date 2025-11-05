<template>
  <div class="bloqueo-domicilios-historico-page">
    <h1>Histórico de Bloqueo de Domicilios</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Histórico de Bloqueo de Domicilios
    </div>
    <div class="toolbar">
      <input v-model="filtro" placeholder="Buscar por calle..." @input="buscar" />
      <button @click="ordenar('calle,num_ext')">Ordenar por Calle y No. Ext.</button>
      <button @click="ordenar('fecha DESC, hora DESC')">Ordenar por Fecha y Hora</button>
      <button @click="ordenar('capturista,fecha DESC,hora DESC')">Ordenar por Capturista</button>
      <button @click="ordenar('modifico,fecha_mov DESC')">Ordenar por Modificó</button>
      <button @click="exportarExcel">Exportar a Excel</button>
      <button @click="imprimirPDF">Imprimir PDF</button>
    </div>
    <table class="table table-striped table-hover">
      <thead>
        <tr>
          <th>Calle</th>
          <th>No. Ext</th>
          <th>Letra Ext</th>
          <th>No. Int</th>
          <th>Letra Int</th>
          <th>Folio</th>
          <th>Fecha</th>
          <th>Vig</th>
          <th>Capturista</th>
          <th>Modificó</th>
          <th>Fecha Mov</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.id">
          <td>{{ row.calle }}</td>
          <td>{{ row.num_ext }}</td>
          <td>{{ row.let_ext }}</td>
          <td>{{ row.num_int }}</td>
          <td>{{ row.let_int }}</td>
          <td>{{ row.folio }}</td>
          <td>{{ row.fecha }}</td>
          <td>{{ row.vig }}</td>
          <td>{{ row.capturista }}</td>
          <td>{{ row.modifico }}</td>
          <td>{{ row.fecha_mov }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="selectedRow">
      <h3>Detalle Histórico</h3>
      <div><strong>Motivo:</strong> {{ selectedRow.motivo_mov }}</div>
      <div><strong>Procedencia:</strong> {{ selectedRow.tipo_mov | procedencia }}</div>
      <div><strong>Observación:</strong> {{ selectedRow.observacion }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BloqueoDomiciliosHistoricoPage',
  data() {
    return {
      rows: [],
      filtro: '',
      order: 'calle,num_ext',
      selectedRow: null
    };
  },
  filters: {
    procedencia(val) {
      if (val === 'EL') return 'Eliminado al Desbloquear de Licencia';
      if (val === 'ED') return 'Eliminado desde Bloqueo de Domicilios';
      if (val === 'MD') return 'Modificado en bloqueo de Domicilio';
      return val;
    }
  },
  methods: {
    async cargar() {
      const eRequest = {
        action: 'listar',
        params: { order: this.order }
      };
      const response = await fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ eRequest })
      });
      const res = await response.json();
      this.rows = res.eResponse.rows;
    },
    async buscar() {
      if (!this.filtro) {
        this.cargar();
        return;
      }
      const eRequest = {
        action: 'filtrar',
        params: { campo: 'calle', valor: this.filtro, order: this.order }
      };
      const response = await fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ eRequest })
      });
      const res = await response.json();
      this.rows = res.eResponse.rows;
    },
    async ordenar(order) {
      this.order = order;
      await this.cargar();
    },
    async exportarExcel() {
      const eRequest = {
        action: 'exportar',
        params: { order: this.order }
      };
      const response = await fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ eRequest })
      });
      const res = await response.json();
      // El frontend debe convertir res.eResponse.rows a Excel
      // Ejemplo: usar SheetJS o similar
      this.$emit('export-excel', res.eResponse.rows);
    },
    async imprimirPDF() {
      const eRequest = {
        action: 'imprimir',
        params: { order: this.order }
      };
      const response = await fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ eRequest })
      });
      const res = await response.json();
      // El frontend debe convertir res.eResponse.rows a PDF
      // Ejemplo: usar jsPDF o similar
      this.$emit('print-pdf', res.eResponse.rows);
    },
    seleccionar(row) {
      this.selectedRow = row;
    }
  },
  mounted() {
    this.cargar();
  }
};
</script>

<style scoped>
.bloqueo-domicilios-historico-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.toolbar {
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.table th {
  background: #f5f5f5;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
</style>
