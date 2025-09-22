<template>
  <div class="consulta-guad-page">
    <h1>Consultas a la base de Datos de Cementerio Guadalajara</h1>
    <div class="consulta-guad-form">
      <div class="consulta-guad-radio-group">
        <label>
          <input type="radio" value="rcm" v-model="consultaTipo" @change="onTipoChange"> Consulta por RCM
        </label>
        <label>
          <input type="radio" value="nombre" v-model="consultaTipo" @change="onTipoChange"> Consulta por NOMBRE
        </label>
        <label>
          <input type="radio" value="partida" v-model="consultaTipo" @change="onTipoChange"> Consulta por PARTIDA
        </label>
      </div>
      <div v-if="consultaTipo === 'rcm'" class="consulta-guad-rcm-fields">
        <label>Clase:
          <input type="number" v-model.number="form.clase" min="1" max="3" />
        </label>
        <label>Sección:
          <input type="number" v-model.number="form.seccion" min="1" />
        </label>
        <label>Línea:
          <input type="number" v-model.number="form.linea" min="1" />
        </label>
      </div>
      <div v-if="consultaTipo === 'nombre'" class="consulta-guad-nombre-fields">
        <label>Nombre:
          <input type="text" v-model="form.nombre" maxlength="60" />
        </label>
      </div>
      <div v-if="consultaTipo === 'partida'" class="consulta-guad-partida-fields">
        <label>Partida:
          <input type="text" v-model="form.partida" maxlength="60" />
        </label>
      </div>
      <div class="consulta-guad-actions">
        <button @click="consultar" :disabled="loading">Consultar</button>
        <button @click="limpiar">Limpiar</button>
      </div>
    </div>
    <div v-if="loading" class="consulta-guad-loading">Consultando...</div>
    <div v-if="error" class="consulta-guad-error">{{ error }}</div>
    <div v-if="resultados.length" class="consulta-guad-resultados">
      <h2>Resultados</h2>
      <table class="consulta-guad-table">
        <thead>
          <tr>
            <th>Clase</th>
            <th>Sección</th>
            <th>Línea</th>
            <th>Fosa</th>
            <th>Partida Pago</th>
            <th>Nombre</th>
            <th>Fecha Compra</th>
            <th>Otros</th>
            <th>Clave</th>
            <th>Medida</th>
            <th>Calle</th>
            <th>Colonia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td>{{ row.clase }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.linea }}</td>
            <td>{{ row.fosa }}</td>
            <td>{{ row.ppago }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.fcompra ? formatFecha(row.fcompra) : '' }}</td>
            <td>{{ row.otros }}</td>
            <td>{{ row.clave }}</td>
            <td>{{ row.medida }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.colonia }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="!resultados.length && !loading">No se encontraron resultados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaGuadPage',
  data() {
    return {
      consultaTipo: 'rcm',
      form: {
        clase: 1,
        seccion: 1,
        linea: 1,
        nombre: '',
        partida: ''
      },
      resultados: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    onTipoChange() {
      this.resultados = [];
      this.error = '';
      if (this.consultaTipo === 'rcm') {
        this.form.clase = 1;
        this.form.seccion = 1;
        this.form.linea = 1;
      } else if (this.consultaTipo === 'nombre') {
        this.form.nombre = '';
      } else if (this.consultaTipo === 'partida') {
        this.form.partida = '';
      }
    },
    async consultar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      let action = '';
      let params = {};
      if (this.consultaTipo === 'rcm') {
        action = 'consulta_por_rcm';
        params = {
          clase: this.form.clase,
          seccion: this.form.seccion,
          linea: this.form.linea
        };
      } else if (this.consultaTipo === 'nombre') {
        action = 'consulta_por_nombre';
        params = {
          nombre: this.form.nombre
        };
      } else if (this.consultaTipo === 'partida') {
        action = 'consulta_por_partida';
        params = {
          partida: this.form.partida
        };
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ action, params })
        });
        const json = await res.json();
        if (json.success) {
          this.resultados = json.data || [];
        } else {
          this.error = json.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    limpiar() {
      this.resultados = [];
      this.error = '';
      this.onTipoChange();
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      // Asume formato ISO
      return new Date(fecha).toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.consulta-guad-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.consulta-guad-form {
  background: #f8f8f8;
  padding: 1rem 2rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}
.consulta-guad-radio-group {
  margin-bottom: 1rem;
}
.consulta-guad-radio-group label {
  margin-right: 2rem;
}
.consulta-guad-rcm-fields label,
.consulta-guad-nombre-fields label,
.consulta-guad-partida-fields label {
  margin-right: 1.5rem;
}
.consulta-guad-actions {
  margin-top: 1rem;
}
.consulta-guad-actions button {
  margin-right: 1rem;
}
.consulta-guad-loading {
  color: #007bff;
  font-weight: bold;
}
.consulta-guad-error {
  color: #c00;
  font-weight: bold;
}
.consulta-guad-resultados {
  margin-top: 2rem;
}
.consulta-guad-table {
  width: 100%;
  border-collapse: collapse;
}
.consulta-guad-table th, .consulta-guad-table td {
  border: 1px solid #ccc;
  padding: 0.4rem 0.6rem;
  text-align: left;
}
.consulta-guad-table th {
  background: #eaeaea;
}
</style>
