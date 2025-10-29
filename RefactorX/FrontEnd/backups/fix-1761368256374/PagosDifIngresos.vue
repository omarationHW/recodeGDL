<template>
  <div class="module-view">
    <h1>Inconsistencias de Pagos</h1>
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="dollar-sign" /></div>
      <div class="module-view-info">
        <h1>Inconsistencias de Pagos</h1>
        <p>Mercados - Inconsistencias de Pagos</p>
      </div>
    </div>

    <div class="module-view-content">
    <form @submit.prevent="onBuscar">
      <div class="form-row align-items-end">
        <div class="form-group col-md-4">
          <label for="recaudadora">Recaudadora</label>
          <select v-model="form.rec" class="municipal-form-control" id="recaudadora" required>
            <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.recaudadora }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="fechaDesde">Fecha desde</label>
          <input type="date" v-model="form.fpadsd" class="municipal-form-control" id="fechaDesde" required />
        </div>
        <div class="form-group col-md-3">
          <label for="fechaHasta">Fecha hasta</label>
          <input type="date" v-model="form.fpahst" class="municipal-form-control" id="fechaHasta" required />
        </div>
        <div class="form-group col-md-2">
          <button type="submit" class="btn btn-primary btn-block">Buscar</button>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group col-md-6">
          <div class="form-check">
            <input class="form-check-input" type="radio" id="tipo1" value="renta" v-model="form.tipo" />
            <label class="form-check-label" for="tipo1">Renta Errónea</label>
          </div>
          <div class="form-check">
            <input class="form-check-input" type="radio" id="tipo2" value="datos" v-model="form.tipo" />
            <label class="form-check-label" for="tipo2">Datos de Pagos y/o cuenta Erróneos</label>
          </div>
        </div>
        <div class="form-group col-md-6 text-right">
          <button v-if="resultados.length" @click="onExportar" type="button" class="btn-municipal-success">Exportar a Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="resultados.length" class="table-responsive mt-3">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="col in columnas" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="!loading && resultados.length === 0 && buscado" class="alert alert-warning mt-3">No se encontraron resultados.</div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosDifIngresosPage',
  data() {
    return {
      recaudadoras: [],
      form: {
        rec: '',
        fpadsd: '',
        fpahst: '',
        tipo: 'renta'
      },
      resultados: [],
      columnas: [],
      loading: false,
      error: '',
      buscado: false
    };
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action: 'getRecaudadoras' } })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.recaudadoras = json.eResponse.data;
          if (this.recaudadoras.length) {
            this.form.rec = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = json.eResponse.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.columnas = [];
      this.buscado = false;
      let action = this.form.tipo === 'renta' ? 'getPagosRentaErronea' : 'getPagosDiferentes';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params: {
                rec: this.form.rec,
                fpadsd: this.form.fpadsd,
                fpahst: this.form.fpahst
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.resultados = json.eResponse.data;
          if (this.resultados.length) {
            this.columnas = Object.keys(this.resultados[0]);
          }
        } else {
          this.error = json.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
        this.buscado = true;
      }
    },
    async onExportar() {
      let action = this.form.tipo === 'renta' ? 'exportPagosRentaErronea' : 'exportPagosDiferentes';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params: {
                rec: this.form.rec,
                fpadsd: this.form.fpadsd,
                fpahst: this.form.fpahst
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success && json.eResponse.data) {
          // Exportar a Excel (simple CSV)
          const rows = json.eResponse.data;
          if (!rows.length) return;
          const cols = Object.keys(rows[0]);
          let csv = cols.join(',') + '\n';
          rows.forEach(r => {
            csv += cols.map(c => '"' + (r[c] !== null ? r[c] : '') + '"').join(',') + '\n';
          });
          const blob = new Blob([csv], { type: 'text/csv' });
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = (this.form.tipo === 'renta' ? 'pagos_renta_erronea' : 'pagos_datos_erroneos') + '.csv';
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.pagos-dif-ingresos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table-responsive {
  max-height: 500px;
  overflow-y: auto;
}
</style>
