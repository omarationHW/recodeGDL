<template>
  <div class="rangoctasfrm-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span>Extractos por Rango de Cuentas</span>
    </div>
    <h2>Impresión de Extractos de Adquiriente por rango de cuentas</h2>
    <div class="form-section">
      <div class="radio-group">
        <label>
          <input type="radio" v-model="mode" value="recaudadora" /> Por Recaudadora
        </label>
        <label>
          <input type="radio" v-model="mode" value="capturista" /> Por Capturista
        </label>
      </div>
      <form @submit.prevent="onSubmit">
        <div v-if="mode === 'recaudadora'">
          <div class="form-row">
            <label>Recaudadora</label>
            <input v-model.number="form.recaud" type="number" required />
          </div>
          <div class="form-row">
            <label>Cuenta Inicial</label>
            <input v-model.number="form.inicial" type="number" required />
          </div>
          <div class="form-row">
            <label>Cuenta Final</label>
            <input v-model.number="form.final" type="number" required />
          </div>
        </div>
        <div v-else>
          <div class="form-row">
            <label>Capturista</label>
            <input v-model="form.capturista" type="text" required />
          </div>
          <div class="form-row">
            <label>Fecha Inicio</label>
            <input v-model="form.fecha_ini" type="date" required />
          </div>
          <div class="form-row">
            <label>Fecha Fin</label>
            <input v-model="form.fecha_fin" type="date" required />
          </div>
        </div>
        <div class="form-row">
          <button type="submit">Imprimir</button>
        </div>
      </form>
      <div v-if="loading" class="loading">Procesando...</div>
      <div v-if="error" class="error">{{ error }}</div>
      <div v-if="result && result.length">
        <h3>Resultados</h3>
        <table class="results-table">
          <thead>
            <tr>
              <th v-for="(col, idx) in columns" :key="idx">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in result" :key="idx">
              <td v-for="col in columns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RangoCtasFrmPage',
  data() {
    return {
      mode: 'recaudadora',
      form: {
        recaud: '',
        inicial: '',
        final: '',
        capturista: '',
        fecha_ini: '',
        fecha_fin: ''
      },
      loading: false,
      error: '',
      result: null,
      columns: []
    };
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.result = null;
      this.loading = true;
      let action = this.mode === 'recaudadora' ? 'print_by_recaudadora' : 'print_by_capturista';
      let params = {};
      if (this.mode === 'recaudadora') {
        params = {
          recaud: this.form.recaud,
          inicial: this.form.inicial,
          final: this.form.final
        };
      } else {
        params = {
          capturista: this.form.capturista,
          fecha_ini: this.form.fecha_ini,
          fecha_fin: this.form.fecha_fin
        };
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.result = data.eResponse.data;
          if (this.result && this.result.length > 0) {
            this.columns = Object.keys(this.result[0]);
          } else {
            this.columns = [];
          }
        } else {
          this.error = data.eResponse.message || 'Error desconocido';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rangoctasfrm-page {
  max-width: 800px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.form-section {
  background: #f9f9f9;
  padding: 1.5rem;
  border-radius: 6px;
  box-shadow: 0 1px 4px #eee;
}
.radio-group {
  margin-bottom: 1rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 140px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  padding: 0.4rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button[type="submit"] {
  background: #003366;
  color: #fff;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  font-weight: bold;
  cursor: pointer;
}
.loading {
  color: #003366;
  font-weight: bold;
}
.error {
  color: #b00;
  font-weight: bold;
  margin-top: 1rem;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
}
.results-table th, .results-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.results-table th {
  background: #e0e0e0;
}
</style>
