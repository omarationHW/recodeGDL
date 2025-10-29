<template>
  <div class="container-fluid py-4">
    <h2 class="mb-3">Reporte de Adeudos Convenios Diversos</h2>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos Convenios Diversos</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport" class="row g-3 mb-4">
      <div class="col-md-2">
        <label class="form-label">Tipo</label>
        <select v-model="form.tipo" class="form-select" required>
          <option v-for="t in tipos" :key="t.value" :value="t.value">{{ t.label }}</option>
        </select>
      </div>
      <div class="col-md-2">
        <label class="form-label">Subtipo</label>
        <select v-model="form.subtipo" class="form-select" required>
          <option v-for="s in subtipos" :key="s.value" :value="s.value">{{ s.label }}</option>
        </select>
      </div>
      <div class="col-md-2">
        <label class="form-label">Zona</label>
        <select v-model="form.letras" class="form-select" required>
          <option value="ZC1">Zona Centro</option>
          <option value="ZO2">Zona Olímpica</option>
          <option value="ZO3">Zona Oblatos</option>
          <option value="ZM4">Zona Minerva</option>
          <option value="ZC5">Zona Cruz del Sur</option>
        </select>
      </div>
      <div class="col-md-2">
        <label class="form-label">Estado</label>
        <select v-model="form.estado" class="form-select" required>
          <option value="A">Vigentes</option>
          <option value="B">Dados de Baja</option>
          <option value="P">Pagados</option>
        </select>
      </div>
      <div class="col-md-2">
        <label class="form-label">Fecha Corte</label>
        <input type="date" v-model="form.fecha" class="form-control" required />
      </div>
      <div class="col-md-2 align-self-end">
        <button type="submit" class="btn btn-primary w-100">Consultar</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle">
          <thead class="table-light">
            <tr>
              <th>Convenio</th>
              <th>Nombre</th>
              <th>Domicilio</th>
              <th>Ext.</th>
              <th>Costo</th>
              <th>Pagos</th>
              <th>Saldo</th>
              <th>Recargos</th>
              <th>Oficio</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in report" :key="row.id_conv_diver">
              <td>{{ row.letras_exp }}/{{ row.numero_exp }}/{{ row.axo_exp }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.calle }} {{ row.num_exterior }} {{ row.num_interior }} {{ row.inciso }}</td>
              <td>{{ row.num_exterior }}</td>
              <td class="text-end">{{ currency(row.cantidad_total) }}</td>
              <td class="text-end">{{ currency(row.pagos) }}</td>
              <td class="text-end">{{ currency(row.cantidad_total - row.pagos) }}</td>
              <td class="text-end">{{ currency(row.recargos) }}</td>
              <td>{{ row.oficio }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-3">
        <button class="btn btn-outline-secondary me-2" @click="exportCSV">Exportar CSV</button>
        <button class="btn btn-outline-secondary" @click="exportPDF">Exportar PDF</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudosConvDiversos',
  data() {
    return {
      form: {
        tipo: '',
        subtipo: '',
        letras: 'ZC1',
        estado: 'A',
        fecha: ''
      },
      tipos: [],
      subtipos: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.loadTipos();
    this.form.fecha = new Date().toISOString().substr(0, 10);
  },
  methods: {
    async loadTipos() {
      // Simulación: cargar tipos y subtipos (en producción, usar API)
      this.tipos = [
        { value: 1, label: 'Predial' },
        { value: 3, label: 'Licencias' },
        { value: 6, label: 'Mercados' },
        { value: 8, label: 'Multas' },
        { value: 13, label: 'Aseo' },
        { value: 17, label: 'Obras Públicas' },
        { value: 18, label: 'Espacios Abiertos' },
        { value: 19, label: 'Estacionamientos' }
      ];
      this.form.tipo = this.tipos[0].value;
      this.loadSubtipos();
    },
    loadSubtipos() {
      // Simulación: cargar subtipos según tipo
      const subtipoMap = {
        1: [ { value: 1, label: 'Predial Urbano' }, { value: 2, label: 'Predial Rústico' } ],
        3: [ { value: 1, label: 'Licencia de Giro' }, { value: 2, label: 'Licencia de Anuncio' } ],
        6: [ { value: 1, label: 'Arrendamiento' }, { value: 2, label: 'Venta de Bienes' } ],
        8: [ { value: 1, label: 'Multa Municipal' } ],
        13: [ { value: 1, label: 'Aseo Contratado' } ],
        17: [ { value: 1, label: 'Obra Pública' } ],
        18: [ { value: 1, label: 'Espacio Abierto' } ],
        19: [ { value: 1, label: 'Estacionamiento Público' }, { value: 2, label: 'Estacionamiento Exclusivo' } ]
      };
      this.subtipos = subtipoMap[this.form.tipo] || [];
      this.form.subtipo = this.subtipos.length > 0 ? this.subtipos[0].value : '';
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getRptAdeudosConvDiversos',
            params: {
              tipo: this.form.tipo,
              subtipo: this.form.subtipo,
              letras: this.form.letras,
              estado: this.form.estado,
              fecha: this.form.fecha
            }
          }
        });
        if (response.data.eResponse.success) {
          this.report = response.data.eResponse.data;
        } else {
          this.error = response.data.eResponse.message || 'Error al consultar el reporte';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    exportCSV() {
      // Exportar a CSV (simple, para demo)
      let csv = 'Convenio,Nombre,Domicilio,Ext.,Costo,Pagos,Saldo,Recargos,Oficio\n';
      this.report.forEach(row => {
        csv += `${row.letras_exp}/${row.numero_exp}/${row.axo_exp},${row.nombre},${row.calle} ${row.num_exterior} ${row.num_interior} ${row.inciso},${row.num_exterior},${row.cantidad_total},${row.pagos},${row.cantidad_total - row.pagos},${row.recargos},${row.oficio}\n`;
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'adeudos_conv_diversos.csv';
      a.click();
      URL.revokeObjectURL(url);
    },
    exportPDF() {
      // Exportar a PDF (requiere librería externa, simulado aquí)
      alert('Funcionalidad de exportar a PDF no implementada en demo.');
    }
  },
  watch: {
    'form.tipo'(val) {
      this.loadSubtipos();
    }
  }
};
</script>

<style scoped>
.table th, .table td { font-size: 0.95rem; }
</style>
