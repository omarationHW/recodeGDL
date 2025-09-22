<template>
  <div class="condueños-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <router-link to="/catastro">Catastro</router-link> /
      <span>Condueños</span>
    </nav>
    <h1>Catálogo de Condueños</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <div class="actions">
        <button @click="goToCreate">Agregar Condueño</button>
      </div>
      <table class="table-condueños">
        <thead>
          <tr>
            <th>Clave</th>
            <th>Nombre Completo</th>
            <th>RFC</th>
            <th>Porcentaje</th>
            <th>Encabeza</th>
            <th>Vigencia</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in condueños" :key="c.cvecont">
            <td>{{ c.cvecont }}</td>
            <td>{{ c.nombre_completo }}</td>
            <td>{{ c.rfc }}</td>
            <td>{{ c.porcentaje }}</td>
            <td>{{ c.encabeza }}</td>
            <td>{{ c.vigencia }}</td>
            <td>
              <button @click="goToEdit(c.cvecont)">Editar</button>
              <button @click="deleteCondueño(c.cvecont)" v-if="c.vigencia === 'V'">Eliminar</button>
              <button @click="restoreCondueño(c.cvecont)" v-if="c.vigencia === 'C'">Restaurar</button>
              <button @click="goToHistory(c.cvecont)">Historial</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="porcentajes">
        <h2>Porcentajes de Copropiedad</h2>
        <ul>
          <li v-for="p in porcentajes" :key="p.cvecont">
            {{ p.nombre_completo }}: {{ p.porcentaje }}% ({{ p.encabeza === 'S' ? 'Encabeza' : 'Copropietario' }})
          </li>
        </ul>
        <div :class="{'error': sumaPorcentaje !== 100, 'ok': sumaPorcentaje === 100}">
          Suma total: {{ sumaPorcentaje }}%
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'CondueñosPage',
  data() {
    return {
      condueños: [],
      porcentajes: [],
      sumaPorcentaje: 0,
      loading: true,
      cvecuenta: null
    };
  },
  created() {
    this.cvecuenta = this.$route.query.cvecuenta || null;
    this.loadCondueños();
  },
  methods: {
    async loadCondueños() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            operation: 'list',
            data: { cvecuenta: this.cvecuenta }
          }
        });
        this.condueños = res.data.eResponse.data || [];
        await this.loadPorcentajes();
      } finally {
        this.loading = false;
      }
    },
    async loadPorcentajes() {
      const res = await axios.post('/api/execute', {
        eRequest: {
          operation: 'porcentajes',
          data: { cvecuenta: this.cvecuenta }
        }
      });
      this.porcentajes = res.data.eResponse.data || [];
      this.sumaPorcentaje = this.porcentajes.reduce((sum, p) => sum + Number(p.porcentaje), 0);
    },
    goToCreate() {
      this.$router.push({ name: 'CondueñosCreate', query: { cvecuenta: this.cvecuenta } });
    },
    goToEdit(cvecont) {
      this.$router.push({ name: 'CondueñosEdit', params: { cvecont } });
    },
    goToHistory(cvecont) {
      this.$router.push({ name: 'CondueñosHistory', params: { cvecont } });
    },
    async deleteCondueño(cvecont) {
      if (!confirm('¿Está seguro de eliminar este condueño?')) return;
      await axios.post('/api/execute', {
        eRequest: {
          operation: 'delete',
          data: { cvecont }
        }
      });
      this.loadCondueños();
    },
    async restoreCondueño(cvecont) {
      await axios.post('/api/execute', {
        eRequest: {
          operation: 'restore',
          data: { cvecont }
        }
      });
      this.loadCondueños();
    }
  }
};
</script>

<style scoped>
.condueños-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.table-condueños {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.table-condueños th, .table-condueños td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.actions {
  margin-bottom: 1rem;
}
.porcentajes {
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
}
.porcentajes .error {
  color: red;
  font-weight: bold;
}
.porcentajes .ok {
  color: green;
  font-weight: bold;
}
.loading {
  font-size: 1.2rem;
  color: #888;
}
</style>
