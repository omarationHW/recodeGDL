<template>
  <div class="gastos-cob-page">
    <h1>Listado de Gastos Cobrados</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Gastos Cobrados</span>
    </div>
    <form @submit.prevent="buscarPagos">
      <div class="form-row">
        <label>Recaudadora:</label>
        <select v-model="form.id_rec" required>
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
            {{ rec.id_rec }} - {{ rec.recaudadora }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Fecha Pago Desde:</label>
        <input type="date" v-model="form.fecha_desde" required />
      </div>
      <div class="form-row">
        <label>Fecha Pago Hasta:</label>
        <input type="date" v-model="form.fecha_hasta" required />
      </div>
      <div class="form-row">
        <label>Tipo Consulta:</label>
        <select v-model="form.tipo_consulta">
          <option value="ofna">Oficina Ingresos</option>
          <option value="apremios">Oficina Apremios</option>
        </select>
      </div>
      <div class="form-actions">
        <button type="submit">Buscar</button>
        <button type="button" @click="exportarExcel" :disabled="!pagos.length">Exportar Excel</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="pagos.length">
      <h2>Resultados</h2>
      <table class="pagos-table">
        <thead>
          <tr>
            <th>Fec_ing</th>
            <th>Recaud</th>
            <th>Caja</th>
            <th>Operac</th>
            <th>Tot-Rbo</th>
            <th>Impte Gastos</th>
            <th>Folio</th>
            <th>Ofna Fol</th>
            <th>Fec-emi</th>
            <th>Fec-pract</th>
            <th>Fec-ejec</th>
            <th>Impte Gastos Folio</th>
            <th>Ejecutor</th>
            <th>Nombre Ejec</th>
            <th>Datos Ref</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in pagos" :key="row.r_folio + '-' + row.r_oper">
            <td>{{ row.r_fecp }}</td>
            <td>{{ row.r_rec }}</td>
            <td>{{ row.r_caja }}</td>
            <td>{{ row.r_oper }}</td>
            <td>{{ row.r_totcert }}</td>
            <td>{{ row.r_imptecta }}</td>
            <td>{{ row.r_folio }}</td>
            <td>{{ row.r_ofnaf }}</td>
            <td>{{ row.r_fecemi }}</td>
            <td>{{ row.r_fecpra }}</td>
            <td>{{ row.r_fecent }}</td>
            <td>{{ row.r_imptegf }}</td>
            <td>{{ row.r_ejecutor }}</td>
            <td>{{ row.r_nomeje }}</td>
            <td>{{ row.r_datos }}</td>
          </tr>
        </tbody>
      </table>
      <div class="summary">
        <strong>Total de Gastos Folios:</strong> {{ totalGastosFolios }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GastosCobPage',
  data() {
    return {
      recaudadoras: [],
      form: {
        id_rec: '',
        fecha_desde: '',
        fecha_hasta: '',
        tipo_consulta: 'ofna'
      },
      pagos: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalGastosFolios() {
      return this.pagos.reduce((sum, row) => sum + (parseFloat(row.r_imptegf) || 0), 0).toFixed(2);
    }
  },
  created() {
    this.cargarRecaudadoras();
  },
  methods: {
    async cargarRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.recaudadoras = data.data;
          if (this.recaudadoras.length) {
            this.form.id_rec = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      let action = this.form.tipo_consulta === 'ofna' ? 'getPagosGastosCob' : 'getPagosGastosCobPorRecaudadora';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action,
            params: {
              fecha_desde: this.form.fecha_desde,
              fecha_hasta: this.form.fecha_hasta,
              id_rec: this.form.id_rec
            }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.pagos = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = 'Error al buscar pagos';
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Exportar a Excel usando una librería JS o backend
      // Aquí solo se muestra un ejemplo simple
      let csv = 'Fec_ing,Recaud,Caja,Operac,Tot-Rbo,Impte Gastos,Folio,Ofna Fol,Fec-emi,Fec-pract,Fec-ejec,Impte Gastos Folio,Ejecutor,Nombre Ejec,Datos Ref\n';
      this.pagos.forEach(row => {
        csv += [
          row.r_fecp, row.r_rec, row.r_caja, row.r_oper, row.r_totcert, row.r_imptecta, row.r_folio, row.r_ofnaf,
          row.r_fecemi, row.r_fecpra, row.r_fecent, row.r_imptegf, row.r_ejecutor, row.r_nomeje, row.r_datos
        ].join(',') + '\n';
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'gastos_cobrados.csv';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.gastos-cob-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  padding: 0.4rem;
}
.form-actions {
  margin-top: 1rem;
}
.pagos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2rem;
}
.pagos-table th, .pagos-table td {
  border: 1px solid #ccc;
  padding: 0.4rem;
  font-size: 0.95rem;
}
.pagos-table th {
  background: #f0f0f0;
}
.summary {
  margin-top: 1rem;
  font-size: 1.1rem;
  font-weight: bold;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
}
</style>
