<template>
  <div class="descpred-formulario">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Descuentos Predial</span>
    </nav>
    <h1>Descuentos de Impuesto Predial</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <div class="actions">
        <button @click="goToAlta">Alta Descuento</button>
        <button @click="fetchDescuentos">Actualizar Lista</button>
      </div>
      <table class="descuentos-table">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Cuenta</th>
            <th>Tipo</th>
            <th>Bim. Ini</th>
            <th>Bim. Fin</th>
            <th>Solicitante</th>
            <th>Identificación</th>
            <th>Institución</th>
            <th>Porcentaje</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="desc in descuentos" :key="desc.id">
            <td>{{ desc.foliodesc }}</td>
            <td>{{ desc.cvecuenta }}</td>
            <td>{{ desc.descripcion }}</td>
            <td>{{ desc.bimini }}</td>
            <td>{{ desc.bimfin }}</td>
            <td>{{ desc.solicitante }}</td>
            <td>{{ desc.identificacion }}</td>
            <td>{{ desc.institucion_nombre }}</td>
            <td>{{ desc.porcentaje }}%</td>
            <td>{{ desc.status === 'V' ? 'Vigente' : (desc.status === 'C' ? 'Cancelado' : 'Otro') }}</td>
            <td>
              <button @click="goToDetalle(desc)">Ver</button>
              <button v-if="desc.status === 'V'" @click="goToEditar(desc)">Editar</button>
              <button v-if="desc.status === 'V'" @click="goToBaja(desc)">Baja</button>
              <button v-if="desc.status === 'C'" @click="goToReactivar(desc)">Reactivar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <router-view/>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'DescpredFormulario',
  data() {
    return {
      descuentos: [],
      loading: false,
      catalogs: {
        tipos: [],
        instituciones: []
      }
    };
  },
  created() {
    this.fetchCatalogs();
    this.fetchDescuentos();
  },
  methods: {
    async fetchCatalogs() {
      this.loading = true;
      const res = await axios.post('/api/execute', {
        action: 'catalogs',
        params: {},
        user: this.$store.state.user
      });
      if (res.data.status === 'success') {
        this.catalogs = res.data.data;
      }
      this.loading = false;
    },
    async fetchDescuentos() {
      this.loading = true;
      const res = await axios.post('/api/execute', {
        action: 'list',
        params: { cvecuenta: this.$route.query.cvecuenta || null },
        user: this.$store.state.user
      });
      if (res.data.status === 'success') {
        this.descuentos = res.data.data.map(d => ({
          ...d,
          institucion_nombre: this.catalogs.instituciones.find(i => i.cveinst === d.institucion)?.institucion || ''
        }));
      }
      this.loading = false;
    },
    goToAlta() {
      this.$router.push({ name: 'DescpredAlta' });
    },
    goToDetalle(desc) {
      this.$router.push({ name: 'DescpredDetalle', params: { id: desc.id } });
    },
    goToEditar(desc) {
      this.$router.push({ name: 'DescpredEditar', params: { id: desc.id } });
    },
    goToBaja(desc) {
      this.$router.push({ name: 'DescpredBaja', params: { id: desc.id } });
    },
    goToReactivar(desc) {
      this.$router.push({ name: 'DescpredReactivar', params: { id: desc.id } });
    }
  }
};
</script>

<style scoped>
.descpred-formulario {
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 1rem;
}
.descuentos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.descuentos-table th, .descuentos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: left;
}
.loading {
  color: #888;
  font-size: 1.2rem;
}
</style>
