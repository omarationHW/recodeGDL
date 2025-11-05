<template>
  <div class="psplash-page">
    <div class="splash-container">
      <div class="splash-image" v-if="splashData.image_base64">
        <img :src="'data:image/jpeg;base64,' + splashData.image_base64" alt="Splash" />
      </div>
      <div class="splash-label-effect">
        <h1 class="label-effect">{{ splashData.label_effect }}</h1>
      </div>
      <div class="splash-version">
        <span class="version-label">{{ versionLabel }}</span>
      </div>
      <div class="splash-message">
        <span>{{ splashData.message }}</span>
      </div>
    </div>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Splash
    </div>
  </div>
</template>

<script>
export default {
  name: 'PsplashPage',
  data() {
    return {
      splashData: {
        message: '',
        label_effect: '',
        image_base64: null
      },
      version: '',
      appName: ''
    };
  },
  computed: {
    versionLabel() {
      return `${this.appName} Versión ${this.version}`;
    }
  },
  methods: {
    async fetchSplashData() {
      try {
        const eRequest = {
          action: 'licencias2.get_splash_data',
          payload: {}
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const res = await response.json();
        this.splashData = res.status === 'success' ? res.eResponse.data.result : {};
      } catch (error) {
        this.splashData = {};
      }
    },
    async fetchVersion() {
      try {
        const eRequest = {
          action: 'licencias2.get_version',
          payload: {}
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const res = await response.json();
        if (res.status === 'success') {
          this.version = res.eResponse.data.result.version || '1.0.0.0';
          this.appName = res.eResponse.data.result.app_name || 'LICENCIAS';
        } else {
          this.version = '1.0.0.0';
          this.appName = 'LICENCIAS';
        }
      } catch (error) {
        this.version = '1.0.0.0';
        this.appName = 'LICENCIAS';
      }
    }
  },
  async mounted() {
    await this.fetchSplashData();
    await this.fetchVersion();
  }
};
</script>

<style scoped>
.psplash-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-height: 100vh;
  background: #f5f5f5;
}
.splash-container {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.08);
  padding: 32px 48px;
  margin-top: 60px;
  text-align: center;
  min-width: 400px;
}
.splash-image img {
  width: 100%;
  max-width: 600px;
  border-radius: 8px;
  margin-bottom: 16px;
}
.splash-label-effect .label-effect {
  font-family: 'Times New Roman', serif;
  font-size: 2.2rem;
  color: #003399;
  text-shadow: 2px 2px 0 #fff, 4px 4px 0 #000;
  margin: 0 0 12px 0;
}
.splash-version .version-label {
  color: #e6b800;
  font-size: 1.1rem;
  font-family: 'Arial Narrow', Arial, sans-serif;
  font-weight: bold;
  margin-bottom: 8px;
  display: block;
}
.splash-message {
  color: #800000;
  font-size: 1rem;
  margin-top: 12px;
}
.breadcrumb {
  margin-top: 24px;
  font-size: 0.95rem;
  color: #888;
}
.breadcrumb a {
  color: #003399;
  text-decoration: none;
}
</style>
