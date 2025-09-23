<template>
  <div class="listado-multiple-page">
    <h1>Listado Múltiple - Convenios Empresas</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Listado Múltiple</span>
    </nav>
    <section class="form-section">
      <form @submit.prevent="buscarConvenios">
        <div class="form-row">
          <label for="year">Año de convenio:</label>
          <input v-model="form.year" id="year" type="number" min="2000" max="2100" required />
        </div>
        <div class="form-row">
          <label for="fecha">Fecha de emisión de folios:</label>
          <input v-model="form.fecha" id="fecha" type="date" required />
        </div>
        <button type="submit">Buscar Convenios</button>
      </form>
    </section>
    <section v-if="convenios.length" class="table-section">
      <h2>Convenios Empresas</h2>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Cve Cuenta</th>
            <th>Cuenta</th>
            <th>Folio Req</th>
            <th>Req Emisión</th>
            <th>Req Vig</th>
            <th>Despacho</th>
            <th>Conv Inicio</th>
            <th>Conv Vig</th>
            <th>Req Pagado</th>
            <th>Conv Pagado</th>
            <th>Parcialidad</th>
            <th>Importe Parcial</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in convenios" :key="row.cvecuenta + '-' + row.folioreq">
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.folioreq }}</td>
            <td>{{ row.req_emision }}</td>
            <td>{{ row.req_vig }}</td>
            <td>{{ row.despacho }}</td>
            <td>{{ row.conv_inicio }}</td>
            <td>{{ row.conv_vig }}</td>
            <td>{{ row.req_pagado }}</td>
            <td>{{ row.conv_pagado }}</td>
            <td>{{ row.parcialidad }}</td>
            <td>{{ row.importe_parcial }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="exportarConveniosExcel">Exportar a Excel</button>
    </section>
    <section class="pagos-section">
      <h2>Pagos de Convenios por Empresa</h2>
      <form @submit.prevent="buscarPagos">
        <div class="form-row">
          <label for="ejecutor">Ejecutor:</label>
          <select v-model="form.ejecutor" id="ejecutor">
            <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">{{ e.empresa }}</option>
          </select>
        </div>
        <div class="form-row">
          <label for="ftrab">Fecha de trabajo:</label>
          <input v-model="form.ftrab" id="ftrab" type="date" required />
        </div>
        <div class="form-row">
          <label for="fpagod">Fecha de pago desde:</label>
          <input v-model="form.fpagod" id="fpagod" type="date" required />
        </div>
        <div class="form-row">
          <label for="fpagoh">Fecha de pago hasta:</label>
          <input v-model="form.fpagoh" id="fpagoh" type="date" required />
        </div>
        <button type="submit">Buscar Pagos</button>
      </form>
      <table v-if="pagos.length" class="table table-striped">
        <thead>
          <tr>
            <th>Cve Cuenta</th>
            <th>Cuenta</th>
            <th>Folio Recibo</th>
            <th>Fecha Pago</th>
            <th>Importe Pago</th>
            <th>Convenio</th>
            <th>Fecha Convenio</th>
            <th>Parc Ini</th>
            <th>Parc Fin</th>
            <th>Cve Req</th>
            <th>Folio Req</th>
            <th>Fecha Req</th>
            <th>Vigencia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in pagos" :key="row.cvecuenta + '-' + row.foliorecibo">
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.foliorecibo }}</td>
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.importe_pago }}</td>
            <td>{{ row.convenio }}</td>
            <td>{{ row.fecha_convenio }}</td>
            <td>{{ row.parc_ini }}</td>
            <td>{{ row.parc_fin }}</td>
            <td>{{ row.cvereq }}</td>
            <td>{{ row.folioreq }}</td>
            <td>{{ row.fecha_req }}</td>
            <td>{{ row.vigencia }}</td>
          </tr>
        </tbody>
      </table>
      <button v-if="pagos.length" @click="exportarPagosExcel">Exportar a Excel</button>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const form = ref({
  year: new Date().getFullYear(),
  fecha: new Date().toISOString().slice(0, 10),
  ejecutor: '',
  ftrab: '',
  fpagod: '',
  fpagoh: ''
});

const convenios = ref([]);
const pagos = ref([]);
const ejecutores = ref([]);

const buscarConvenios = async () => {
  const res = await axios.post('/api/execute', {
    action: 'getConveniosEmpresas',
    params: { year: form.value.year, fecha: form.value.fecha }
  });
  convenios.value = res.data.data || [];
};

const buscarPagos = async () => {
  const res = await axios.post('/api/execute', {
    action: 'getPagosConveniosEmpresas',
    params: {
      ejecutor: form.value.ejecutor,
      ftrab: form.value.ftrab,
      fpagod: form.value.fpagod,
      fpagoh: form.value.fpagoh
    }
  });
  pagos.value = res.data.data || [];
};

const cargarEjecutores = async () => {
  const res = await axios.post('/api/execute', {
    action: 'getEjecutoresEmpresas',
    params: { ftrabajo: form.value.ftrab || new Date().toISOString().slice(0, 10) }
  });
  ejecutores.value = res.data.data || [];
};

const exportarConveniosExcel = () => {
  // Implementar exportación a Excel (puede ser backend o frontend)
  alert('Exportar a Excel no implementado en este demo');
};

const exportarPagosExcel = () => {
  // Implementar exportación a Excel (puede ser backend o frontend)
  alert('Exportar a Excel no implementado en este demo');
};

onMounted(() => {
  buscarConvenios();
  cargarEjecutores();
});
</script>

<style scoped>
.listado-multiple-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-section, .pagos-section {
  margin-bottom: 2rem;
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 8px;
}
.table-section {
  margin-bottom: 2rem;
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
  background: #e0e0e0;
}
</style>
