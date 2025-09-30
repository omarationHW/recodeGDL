<template>
  <div class="giros-vigentes-cte-xgiro">
    <h1 class="text-center">REPORTE DE GIROS VIGENTES CON CORTE POR GIRO</h1>
    <div class="panel panel-default mb-3">
      <div class="panel-body">
        <div class="row mb-2">
          <div class="col-md-6">
            <label><strong>Por año</strong></label>
            <div class="form-inline">
              <label class="mr-2">Año de alta/baja:</label>
              <input type="number" v-model="form.year" class="form-control mr-2" min="1900" max="2100" @input="onYearInput" />
            </div>
          </div>
          <div class="col-md-6">
            <label><strong>Por rango de fechas</strong></label>
            <div class="form-inline">
              <label class="mr-2">Fechas:</label>
              <input type="date" v-model="form.date_from" class="form-control mr-2" @change="onDateRangeInput" />
              <input type="date" v-model="form.date_to" class="form-control" @change="onDateRangeInput" />
            </div>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-6">
            <label>Filtrado por:</label>
            <div>
              <label class="mr-2"><input type="radio" value="V" v-model="form.vigente" /> Vigentes</label>
              <label><input type="radio" value="C" v-model="form.vigente" /> Cancelados</label>
            </div>
          </div>
          <div class="col-md-6">
            <label>Ordenado por:</label>
            <div>
              <label class="mr-2"><input type="radio" value="cuantos" v-model="form.order_by" /> Número de concurrencias</label>
              <label><input type="radio" value="descripcion" v-model="form.order_by" /> Descripción</label>
            </div>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-12">
            <label>Clasificación:</label>
            <div>
              <label class="mr-2"><input type="radio" value="" v-model="form.clasificacion" /> Todas</label>
              <label class="mr-2"><input type="radio" value="A" v-model="form.clasificacion" /> Solo A</label>
              <label class="mr-2"><input type="radio" value="B" v-model="form.clasificacion" /> Solo B</label>
              <label class="mr-2"><input type="radio" value="C" v-model="form.clasificacion" /> Solo C</label>
              <label><input type="radio" value="D" v-model="form.clasificacion" /> Solo D</label>
            </div>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 text-right">
            <button class="btn btn-primary" @click="onBuscar">Buscar</button>
            <button class="btn btn-secondary ml-2" @click="onImprimir" :disabled="loading || !reporte.length">Imprimir</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reporte.length">
      <h3 class="mt-4">Resultados</h3>
      <table class="table table-bordered table-striped">
        <thead>
          <tr>
            <th>Descripción del giro</th>
            <th>Código Giro</th>
            <th>Concurrencias</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reporte" :key="row.id_giro">
            <td>{{ row.descripcion }}</td>
            <td>{{ row.cod_giro }}</td>
            <td class="text-right">{{ row.cuantos }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="2" class="text-right">Total de giros:</th>
            <th class="text-right">{{ totalGiros }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GirosVigentesCteXgiro',
  data() {
    return {
      form: {
        year: '',
        date_from: '',
        date_to: '',
        vigente: 'V',
        clasificacion: '',
        order_by: 'cuantos'
      },
      reporte: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalGiros() {
      return this.reporte.reduce((acc, row) => acc + Number(row.cuantos), 0);
    }
  },
  methods: {
    onYearInput() {
      if (this.form.year) {
        this.form.date_from = '';
        this.form.date_to = '';
      }
    },
    onDateRangeInput() {
      if (this.form.date_from || this.form.date_to) {
        this.form.year = '';
      }
    },
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getReporteGiros',
            params: {
              year: this.form.year ? parseInt(this.form.year) : null,
              date_from: this.form.date_from || null,
              date_to: this.form.date_to || null,
              vigente: this.form.vigente,
              clasificacion: this.form.clasificacion || null,
              order_by: this.form.order_by
            }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.reporte = json.data;
        } else {
          this.error = json.message || 'Error al obtener datos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onImprimir() {
      // Puede abrir una ventana de impresión o descargar PDF
      // Por ahora, solo muestra alerta
      alert('Funcionalidad de impresión no implementada.');
      // O bien, llamar a un endpoint que genere PDF
      // await fetch('http://localhost:8000/api/generic', { ... });
    }
  }
};
</script>

<style scoped>
.giros-vigentes-cte-xgiro {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
